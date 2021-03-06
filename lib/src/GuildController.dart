/*
BSD 3-Clause License

Copyright (c) 2018, Benny Jacobs
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
import 'dart:async';
import 'dart:html';
import 'package:discord/discord.dart' as discord;
import 'package:discord/browser.dart' as discord;
import 'package:discordshell/src/model/DiscordShellBot.dart';
import './ChannelController.dart';
import 'package:discordshell/src/model/OpenChannelRequestEvent.dart';

class GuildController {
  final DiscordShellBot _ds;
  discord.Guild _guild;
  final DivElement _view;
  final List<ChannelController> _subControllers = new List<ChannelController>();

  final ImageElement _image;
  final HtmlElement _title;
  final DivElement _guildChannels;
  final TemplateElement _channelTemplate;

  final StreamController<OpenChannelRequestEvent> _onOpenChannelRequestEventStreamController;
  final Stream<OpenChannelRequestEvent> onOpenChannelRequestEvent;

  GuildController._internal(this._ds, this._guild, this._view, this._onOpenChannelRequestEventStreamController, this.onOpenChannelRequestEvent) :
    _image = _view.querySelector('img'),
    _title = _view.querySelector('.guild-title'),
    _guildChannels = _view.querySelector('div.guild-channels'),
    _channelTemplate = _view.querySelector('template[name="channel-template"]')
  {
    assert(_channelTemplate != null);

    this._updateView();

    _guild.channels.forEach((key, channel) {
      this._createGuildChannel(channel);
    });

    this._ds.bot.onChannelCreate.listen((e) {
      discord.Channel channel = e.channel;

      if(channel is discord.GuildChannel) {
        assert(channel.guild.id != _guild.id || (channel.guild.id == _guild.id && channel.guild == _guild));

        if(channel.guild == _guild) {
          this._createGuildChannel(channel);
        }
      }
    });

    this._ds.bot.onGuildUpdate.listen((e) {
      assert(e.oldGuild.id != _guild.id || (e.oldGuild.id == _guild.id && e.oldGuild == _guild));
      if(e.oldGuild == _guild) {
        assert(e.newGuild.channels.length == _guild.channels.length);
        this._guild = e.newGuild;
      }
    });
  }

  factory GuildController(DiscordShellBot ds, discord.Guild guild, HtmlElement parent, TemplateElement _guildTemplate) {
    DocumentFragment fragment = document.importNode(_guildTemplate.content, true);
    DivElement view = fragment.querySelector('div.guild-pane');
    parent.append(view);

    StreamController<OpenChannelRequestEvent> streamController = new StreamController<OpenChannelRequestEvent>.broadcast();
    Stream<OpenChannelRequestEvent> stream = streamController.stream;

    return new GuildController._internal(ds, guild, view, streamController, stream);
  }

  _updateView() {
    _image.title = _guild.id;
    if(this._guild.icon == null)
    {
      _image.src = "images/iconless.png";
    }
    else
    {
      // TODO: Request webp if user agent supports it.
      _image.src = _guild.iconURL(format: 'png');
    }

    _title.text = _guild.name;
    _title.title = _guild.id;
  }

  _createGuildChannel(discord.GuildChannel guildChannel) {
    if(guildChannel.type == 'text') {
      ChannelController controller = new ChannelController(_ds, guildChannel, this._guildChannels, _channelTemplate);
      controller.onOpenChannelRequestEvent.listen((e) {
        assert(e.channel != null);
        this._onOpenChannelRequestEventStreamController.add(e);
      });
      this._subControllers.add(controller);
    }
  }

  Future<Null> destroy() async {
    await this._onOpenChannelRequestEventStreamController.close();
    for(ChannelController controller in this._subControllers) {
      await controller.destroy();
    }
    return null;
  }
}
