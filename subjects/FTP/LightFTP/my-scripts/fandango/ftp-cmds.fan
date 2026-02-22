from random import randint

<start> ::= <banner_exchange> <unauthenticated_state>
<banner_exchange> ::= <ServerControl:greeting_block>
<greeting_block> ::= "220" <response_tail>

# ---- STATE DEFINITIONS ----
<unauthenticated_state> ::= <unauthenticated_exchanges>
<unauthenticated_exchanges> ::= <AUTH_exchange><authenticated_state>
<authenticated_state> ::= (<control_exchanges> <authenticated_state>) | ((<PASV_exchange> | <EPSV_exchange>) <data_connected_state>) | <QUIT_exchange>
<data_connected_state> ::= <control_exchanges> <data_connected_state> | <data_exchanges> <authenticated_state>
<control_exchanges> ::= (<PROT_exchange> | <AUTH_CMD_exchange> | <PBSZ_exchange> | <OPTS_exchange> |  <FEAT_exchange> | <SIZE_exchange> | <REST_exchange> | <TYPE_exchange> | <SITE_exchange> | <NOOP_exchange> | <SYST_exchange> | <PORT_exchange> | <HELP_exchange> | (<RNFR_exchange> <RNTO_exchange>?) | <RMD_exchange> | <MKD_exchange> | <PWD_exchange> | <CWD_exchange> | <CDUP_exchange> | <DELE_exchange>)
<data_exchanges> ::= <STOR_exchange> | <ABOR_exchange> | <APPE_exchange> | <RETR_exchange> | <MLSD_exchange>

# ---- EXCHANGES ----
<AUTH_exchange> ::= <ClientControl:USER> <ServerControl:USER_response> <ClientControl:PASS> <ServerControl:PASS_response>
<QUIT_exchange> ::= <ClientControl:QUIT> <ServerControl:QUIT_response>
<PORT_exchange> ::= <ClientControl:PORT> <ServerControl:PORT_response>
<DELE_exchange> ::= <ClientControl:DELE> <ServerControl:DELE_response>
<RNFR_exchange> ::= <ClientControl:RNFR> <ServerControl:RNFR_response>
<RNTO_exchange> ::= <ClientControl:RNTO> <ServerControl:RNTO_response>
<CWD_exchange> ::= <ClientControl:CWD> <ServerControl:CWD_response>
<CDUP_exchange> ::= <ClientControl:CDUP> <ServerControl:CDUP_response>
<PWD_exchange> ::= <ClientControl:PWD> <ServerControl:PWD_response>
<MKD_exchange> ::= <ClientControl:MKD> <ServerControl:MKD_response>
<RMD_exchange> ::= <ClientControl:RMD> <ServerControl:RMD_response>
<HELP_exchange> ::= <ClientControl:HELP> <ServerControl:HELP_response>
<SYST_exchange> ::= <ClientControl:SYST> <ServerControl:SYST_response>
<NOOP_exchange> ::= <ClientControl:NOOP> <ServerControl:NOOP_response>
<SITE_exchange> ::= <ClientControl:SITE> <ServerControl:SITE_response>
<TYPE_exchange> ::= <ClientControl:TYPE> <ServerControl:TYPE_response>
<PASV_exchange> ::= <ClientControl:PASV> <ServerControl:PASV_response>
<ABOR_exchange> ::= <ClientControl:ABOR> (<ServerControl:ABOR_response> <SocketControlServer:close_data> | <SocketControlServer:close_data> <ServerControl:ABOR_response>)
<APPE_exchange> ::= <ClientControl:APPE> <ServerControl:Response_150> (<ClientData:APPE_data>* <SocketControlClient:close_data>)? <ServerControl:Response_226>
<LIST_exchange> ::= <ClientControl:LIST> <ServerControl:Response_150> <ServerData:LIST_data>* (<SocketControlServer:close_data> <ServerControl:Response_226> | <ServerControl:Response_226> <ServerData:LIST_data>* <SocketControlServer:close_data>)
<REST_exchange> ::= <ClientControl:REST> <ServerControl:REST_response>
<RETR_exchange> ::= <ClientControl:RETR> <ServerControl:Response_150> <ServerData:FILE_data>* (<SocketControlServer:close_data> <ServerControl:Response_226> | <ServerControl:Response_226> <ServerData:FILE_data>* <SocketControlServer:close_data>)
<STOR_exchange> ::= <ClientControl:STOR> <ServerControl:Response_150> (<ClientData:FILE_data>* <SocketControlClient:close_data>)? <ServerControl:Response_226>
<FEAT_exchange> ::= <ClientControl:FEAT> <ServerControl:FEAT_response>
<SIZE_exchange> ::= <ClientControl:SIZE> <ServerControl:SIZE_response>
<OPTS_exchange> ::= <ClientControl:OPTS> <ServerControl:OPTS_response>
<MLSD_exchange> ::= <ClientControl:MLSD> <ServerControl:Response_150> <ServerData:MLSD_data>* (<SocketControlServer:close_data> <ServerControl:Response_226> | <ServerControl:Response_226> <SocketControlServer:close_data>)
<AUTH_CMD_exchange> ::= <ClientControl:AUTH> <ServerControl:AUTH_response>
<PBSZ_exchange> ::= <ClientControl:PBSZ> <ServerControl:PBSZ_response>
<PROT_exchange> ::= <ClientControl:PROT> <ServerControl:PROT_response>
<EPSV_exchange> ::= <ClientControl:EPSV> <ServerControl:EPSV_response>

<APPE_data> ::= r"[\s\S]*"
<LIST_data> ::= r"[\s\S]*"
<FILE_data> ::= r"[\s\S]*"
<MLSD_data> ::= r"[\s\S]*"
<close_data> ::= <close_data_inner>
<close_data_inner> ::= "999 Data socket closed." <crlf>

where str(<APPE>.<file>) == "exist_append.txt"
where str(<RETR>.<file>) == "exist_append.txt"
where str(<DELE>.<file>) != "exist_append.txt"
where str(<RNFR>.<dir_file>) == "dir_1/dir_2/rn_1.txt" or str(<RNFR>.<dir_file>) == "dir_1/dir_2/rn_2.txt"
where str(<RNTO>.<dir_file>) == "dir_1/dir_2/rn_1.txt" or str(<RNTO>.<dir_file>) == "dir_1/dir_2/rn_2.txt"
where str(<MLSD>.<directory>) == "dir" or str(<MLSD>.<directory>) == "dir_1/dir_2"


# ---- CLIENT COMMANDS ----
<QUIT> ::= "QUIT" <crlf>
<USER> ::= "USER" <space> <word> <crlf>
<PASS> ::= "PASS" <space> <text> <crlf>
<PORT> ::= "PORT" <space> <ip_6_tuple> <crlf>
<RNFR> ::= "RNFR" <space> <dir_file> <crlf> # File might not exist
<RNTO> ::= "RNTO" <space> <dir_file> <crlf> # File might not exist
<DELE> ::= "DELE" <space> <file> <crlf> # File might not exist
<CDUP> ::= "CDUP" <crlf>
<CWD> ::= "CWD" <space> <directory> <crlf> # Dir might not exist
<PWD> ::= "PWD" <crlf>
<MKD> ::= "MKD" <space> <filesystem_name> <crlf> # File might already exist
<RMD> ::= "RMD" <space> <filesystem_name> <crlf> # File might not exist
<SYST> ::= "SYST" <crlf>
<HELP> ::= "HELP" <crlf>
<NOOP> ::= "NOOP" <crlf>
<SITE> ::= "SITE" <space> <text> <crlf>
<TYPE> ::= "TYPE" <space> ("A" (<space> "N")? | "I") <crlf>
<PASV> ::= "PASV" <crlf>
<ABOR> ::= "ABOR" <crlf>
<APPE> ::= "APPE" <space> <file> <crlf> # File might not exist
<LIST> ::= "LIST" (<space> <directory>)? <crlf> # Dir might not exist
<REST> ::= "REST" <space> <marker> <crlf>
<RETR> ::= "RETR" <space> <file> <crlf>
<STOR> ::= "STOR" <space> <file> <crlf>

<FEAT> ::= "FEAT" <crlf>
<SIZE> ::= "SIZE" <space> <dir_file> <crlf>
<OPTS> ::= "OPTS" <space> <text> <crlf>
<MLSD> ::= "MLSD" (<space> <directory>)? <crlf>
<AUTH> ::= "AUTH" <space> <text> <crlf>
<PBSZ> ::= "PBSZ" <space> <number> <crlf>
<PROT> ::= "PROT" <space> ("C" | "S" | "E" | "P") <crlf>
<EPSV> ::= "EPSV" <crlf>

# Implementation specific command. This one works with lightFTP
where str(<SITE>.<text>) == "HELP"

# ---- SERVER COMMAND RESPONSES ----
# <QUIT_response> ::= "221" <response_tail>
# <USER_response> ::= "331" <response_tail>
# <PASS_response> ::= "230" <response_tail>
# <PORT_response> ::= "200" <response_tail>
# <DELE_response> ::= "250" <response_tail>
# <RNFR_response> ::= "350" <response_tail>
# <RNTO_response> ::= "250" <response_tail>
# <CWD_response> ::= "250" <response_tail>
# <CDUP_response> ::= "250" <response_tail>
# <PWD_response> ::= "257" <response_tail_with_absolute_path>
# <MKD_response> ::= "257" <response_tail_with_absolute_path>
# <RMD_response> ::= "250" <response_tail>
# <SYST_response> ::= "215" <response_tail>
# <HELP_response> ::= ("211-" | "214-") <text> <crlf> (r"(?s)^.*?(?=\r\n(214|211)|$)" <crlf>)* ("214" | "211") <response_tail>
# <NOOP_response> ::= "200" <response_tail>
# <SITE_response> ::= r"2\d\d" <response_tail>
# <TYPE_response> ::= "200" <response_tail>
# <PASV_response> ::= "227" <response_tail>
# <ABOR_response> ::= "226" <response_tail>
# <PASV_response> ::= "227" <response_tail>
# <LIST_response> ::= ("226" | "250") <response_tail>
# <REST_response> ::= ("350") <response_tail>
# <RETR_response> ::= ("226" | "250") <response_tail>
# <STOR_response> ::= ("226" | "250") <response_tail>
# <FEAT_response> ::= "211" <response_tail>
# <SIZE_response> ::= "213" <response_tail>
# <OPTS_response> ::= "200" <response_tail>
# <MLSD_response> ::= "200" <response_tail>
# <AUTH_response> ::= "234" <response_tail>
# <PBSZ_response> ::= "200" <response_tail>
# <PROT_response> ::= "200" <response_tail>
# <EPSV_response> ::= "229" <response_tail>

<QUIT_response> ::= <catch_all_response>
<USER_response> ::= <catch_all_response>
<PASS_response> ::= <catch_all_response>
<PORT_response> ::= <catch_all_response>
<DELE_response> ::= <catch_all_response>
<RNFR_response> ::= <catch_all_response>
<RNTO_response> ::= <catch_all_response>
<CWD_response> ::= <catch_all_response>
<CDUP_response> ::= <catch_all_response>
<PWD_response> ::= <catch_all_response>
<MKD_response> ::= <catch_all_response>
<RMD_response> ::= <catch_all_response>
<SYST_response> ::= <catch_all_response>
<HELP_response> ::= <catch_all_response>
<NOOP_response> ::= <catch_all_response>
<SITE_response> ::= <catch_all_response>
<TYPE_response> ::= <catch_all_response>
<PASV_response> ::= '227'  (<space> <text>)? <space> "(" <pasv_socket> ")" <text>? <crlf>
<ABOR_response> ::= <catch_all_response>
<LIST_response> ::= <catch_all_response>
<REST_response> ::= <catch_all_response>
<RETR_response> ::= <catch_all_response>
<STOR_response> ::= <catch_all_response>
<FEAT_response> ::= <catch_all_response>
<SIZE_response> ::= <catch_all_response>
<OPTS_response> ::= <catch_all_response>
<AUTH_response> ::= <catch_all_response>
<PBSZ_response> ::= <catch_all_response>
<PROT_response> ::= <catch_all_response>
<EPSV_response> ::= '229 Entering Extended Passive Mode (|||' <open_port> '|)\r\n'
<Response_150> ::= "150" <response_tail>
<Response_226> ::= "226" <response_tail>
<catch_all_response> ::= r"[\s\S]*"


<pasv_socket> ::= <socket_addr> := set_pasv_socket(<open_pasv_socket>)
<open_pasv_socket> ::= <socket_addr> := set_pasv_socket(<pasv_socket>)
<socket_addr> ::= <ip_number> "," <ip_number> "," <ip_number> "," <ip_number> "," <port_nr_1> "," <port_nr_2>


<response_tail> ::= (<space> <text>) <crlf>
<response_tail_with_absolute_path> ::= (r"^.*?(?=\x22)")? "\"" "/"? <directory> ("/\"\"" <directory> "\"\"")? "\"" <text>? <crlf>
<text> ::= r"[^\r\n\x80-\xFF]+"
<word> ::= r"[\x00-\x1F\x21-\x7F]+"
<number> ::= r"(0|[1-9][0-9]*)"
<space> ::= " "
<crlf> ::= "\r\n"
<ip_6_tuple> ::= <ip_number_1> "," <ip_number> "," <ip_number> "," <ip_number> "," <port_nr_1> "," <port_nr_2>
<ip_number_1> ::= <ip_number>
<ip_number> ::= r'[0-9]+' := str(randint(0, 254))
<port_nr_1> ::= r'[0-9]+' := str(randint(1, 255))
<port_nr_2> ::= r'[0-9]+' := str(randint(1, 255))
<dir_file> ::= (<directory> '/')? <file>
<directory> ::= <filesystem_name> ("/" <filesystem_name>)*
<file> ::= <filesystem_name> ('.' <filesystem_name>)?
<filesystem_name> ::= r'[a-zA-Z0-9\_]+'
<marker> ::= r"[a-zA-Z0-9\-\.]+"

<open_port> ::= <passive_port> := open_data_port(int(<open_port_param>))
<open_port_param> ::= <passive_port> := open_data_port(int(<open_port>))
<passive_port> ::= r'[1-9][0-9]{0,4}'


# Not part of RFC. We set the correct user and password per constraint
where str(<USER>.<word>) == "webadmin"
where str(<PASS>.<text>) == "ubuntu"

where int(str(<PORT>..<ip_number>)) < 256
where int(str(<PORT>..<ip_number_1>)) > 0
where int(str(<port_nr_2>)) < 256
where forall <port_req> in <PORT>:
    int(str(<port_req>..<port_nr_1>)) * 256 + int(str(<port_req>..<port_nr_2>)) < 65536
where forall <port_req> in <PORT>:
    int(str(<port_req>..<port_nr_1>)) * 256 + int(str(<port_req>..<port_nr_2>)) > 1023

def set_pasv_socket(pasv_socket) -> str:
    pasv_socket = pasv_socket[0]
    ip = f"{pasv_socket[0]}.{pasv_socket[2]}.{pasv_socket[4]}.{pasv_socket[6]}"
    port = (int(pasv_socket[8]) * 256) + int(pasv_socket[10])
    try:
        client_data = ClientData.instance()
        server_data = ServerData.instance()
    except KeyError:
        # Party instances not created
        return port
    client_data.stop()
    #if client_data.ip != ip:
    #    client_data.ip = ip
    if client_data.port != port:
        client_data.port = port
    client_data.start()

    #if server_data.ip != ip:
    #    server_data.ip = ip
    if server_data.port != port:
        server_data.port = port
    return str(pasv_socket)

def open_data_port(port) -> int:
    try:
        client_data = ClientData.instance()
        server_data = ServerData.instance()
    except KeyError:
        # Party instances not created
        return port

    client_data.stop()
    if client_data.port != port:
        client_data.port = port
    client_data.start()
    if server_data.port != port:
        server_data.port = port
    return port