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
import './DiscordShellBot.dart';
import './NewDiscordShellEvent.dart';

class DiscordShellBotCollection {
  final List<DiscordShellBot> discordShells = new List<DiscordShellBot>();

  final StreamController<NewDiscordShellEvent> _onNewDiscordShellStreamController;
  final Stream<NewDiscordShellEvent> onNewDiscordShell;

  DiscordShellBotCollection._internal(this._onNewDiscordShellStreamController, this.onNewDiscordShell) {

  }

  factory DiscordShellBotCollection() {

    StreamController<NewDiscordShellEvent> streamController = new StreamController<NewDiscordShellEvent>.broadcast();
    Stream<NewDiscordShellEvent> stream = streamController.stream;

    return new DiscordShellBotCollection._internal(streamController, stream);
  }

  addDiscordShell(DiscordShellBot discordShell) {
    discordShells.add(discordShell);
    this._onNewDiscordShellStreamController.add(new NewDiscordShellEvent(discordShell));
  }

  removeDiscordShell(DiscordShellBot discordShell) {
    throw new UnimplementedError();
  }

  Future<Null> destroy() async {
    await this._onNewDiscordShellStreamController.close();
    return null;
  }
}
