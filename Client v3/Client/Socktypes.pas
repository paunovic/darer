unit Socktypes;

interface

uses
  Windows, WinSock2;

const
// RFC1340 ethernet protocols
  PROTO_PUP     =	$0200;
  PROTO_XNS     =	$0600;
  PROTO_IP      =	$0800;
  PROTO_ARP     =	$0806;
  PROTO_REVARP  =	$0835;
  PROTO_SCA     =	$6007;
  PROTO_ATALK   =	$809B;
  PROTO_AARP    =	$80F3;
  PROTO_IPX     =	$8137;
  PROTO_NOVELL  =	$8138;
  PROTO_SNMP    =	$814C;
  PROTO_IPV6    =	$86DD;
  PROTO_XIMETA  =	$88AD;
  PROTO_LOOP    =	$900D;

  OFFSET_IP     =	14;   // length of ethernet frame header

  TCP_FLAG_FIN  =	$01;  // TCP flags
  TCP_FLAG_SYN  =	$02;
  TCP_FLAG_RST  =	$04;
  TCP_FLAG_PSH  =	$08;
  TCP_FLAG_ACK  =	$10;
  TCP_FLAG_URG  =	$20;
  TCP_FLAG_ECH  =	$40;
  TCP_FLAG_CWR  =	$80;

type
// IP header (RFC 791) - Internet Layer
  THdrIP = packed record
             ihl_ver  : BYTE;        // Combined field:
                                     //   ihl:4 - IP header length divided by 4
                                     //   version:4 - IP version
             tos      : BYTE;        // IP type-of-service field
             tot_len  : WORD;        // total length
             id       : WORD;        // unique ID
             frag_off : WORD;        // Fragment Offset + fragmentation flags (3 bits)
             ttl      : BYTE;        // time to live
             protocol : BYTE;        // protocol type
             check    : WORD;        // IP header checksum
             saddr    : TInAddr;     // source IP
             daddr    : TInAddr;     // destination IP
             {The options start here...}
           end;
  PHdrIP = ^THdrIP;

implementation

end.
