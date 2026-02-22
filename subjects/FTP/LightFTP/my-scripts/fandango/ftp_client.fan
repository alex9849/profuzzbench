include('ftp-cmds.fan')

# The classes ClientControl and ServerControl are the party definitions for the control connection.
class ClientControl(NetworkParty):
    def __init__(self):
        super().__init__(
            connection_mode=ConnectionMode.CONNECT,
            uri="tcp://127.0.0.1:2200"
        )
        self.start()

    def send(self, message: str | bytes, recipient: Optional[str]) -> None:
        super().send(message, recipient)

    def receive(self, message: str | bytes, sender: Optional[str]) -> None:
        if message.decode("utf-8").startswith("226"):
            ClientData.instance().stop()
        super().receive(message.decode("utf-8"), sender="ServerControl")


class ServerControl(NetworkParty):
    def __init__(self):
        super().__init__(
            connection_mode=ConnectionMode.EXTERNAL,
            uri="tcp://127.0.0.1:2200"
        )
        self.start()

class ClientData(NetworkParty):
    def __init__(self):
        super().__init__(
            connection_mode=ConnectionMode.CONNECT,
            uri="tcp://127.0.0.1:50100"
        )

    def start(self):
        print("STARTING")
        super().start()

    def receive(self, message: str | bytes, sender: Optional[str]) -> None:
        super().receive(message.decode("utf-8"), sender="ServerData")


class ServerData(NetworkParty):
    def __init__(self):
        super().__init__(
            connection_mode=ConnectionMode.EXTERNAL,
            uri="tcp://127.0.0.1:50100"
        )
