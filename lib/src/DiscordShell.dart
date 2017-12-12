/*
BSD 3-Clause License

Copyright (c) 2017, Benny Jacobs
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
import 'dart:html';
import 'package:discord/discord.dart' as discord;
import 'package:discord/browser.dart' as discord;
import 'ChatPane.dart';

class DiscordShell {
  discord.Client bot;

  DiscordShell (DocumentFragment container, String token) {
    Element statusHTML = container.querySelector('.discord-shell-status');
    Element guildsHTML = container.querySelector('.guild-panes');
    Element chatsHTML = container.querySelector('.chat-panes');
    TemplateElement guildTemplateHTML = container.querySelector('template[name=guild-pane-template]');
    TemplateElement chatTemplateHTML = container.querySelector('template[name=chat-pane-template]');

    assert(statusHTML != null);
    assert(guildsHTML != null);
    assert(guildTemplateHTML != null);
    assert(chatTemplateHTML != null);

    statusHTML.text = 'Running~';
    discord.configureDiscordForBrowser();
    bot = new discord.Client(token);

    bot.onReady.listen((discord.ReadyEvent e) async {
      bot.guilds.forEach((key, guild) {
          DocumentFragment guildContainer = document.importNode(guildTemplateHTML.content, true);
          assert(guildContainer != null);
          ImageElement image = guildContainer.querySelector('img');
          image.src = guild.iconURL();
          Element title = guildContainer.querySelector('.guild-title');
          title.text = guild.name;
          guildsHTML.append(guildContainer);
      });

      DocumentFragment chatContainer = document.importNode(chatTemplateHTML.content, true);
      ChatPane chatPane = new ChatPane(chatContainer, bot);
      chatsHTML.append(chatContainer);
    });

    bot.onGuildCreate.listen((discord.GuildCreateEvent e) {
      print("Joined" + " " + e.guild.name);
    });

    bot.onGuildUpdate.listen((discord.GuildUpdateEvent e) {
      if(e.oldGuild.name != e.newGuild.name)
      {
        print("Guild" + " " + e.oldGuild.name + " " + "changed into" + " " + e.newGuild.name);
      }
      else
      {
        print("Guild" + " " + e.newGuild.name + " " + "changed");
      }
    });

    bot.onGuildDelete.listen((discord.GuildDeleteEvent e) {
      print("Left" + " " + e.guild.name);
    });
  }

}
