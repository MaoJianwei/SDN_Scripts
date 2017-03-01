from ryu.base import app_manager
from ryu.controller import ofp_event
from ryu.controller.handler import set_ev_cls, MAIN_DISPATCHER
from ryu.lib.packet.packet import Packet
from ryu.lib.packet.ethernet import ethernet
from ryu.lib.packet.ipv4 import ipv4
from ryu.lib.packet.tcp import tcp
from ryu.lib.packet.ether_types import ETH_TYPE_IP
from ryu.lib import addrconv
from ryu.lib import mac
import struct
import time


class MaoLimitWeb(app_manager.RyuApp):
	def __init__(self,*args,**kwargs):
		super(MaoLimitWeb,self).__init__(*args,**kwargs)
		self.oldT = 0

	@set_ev_cls(ofp_event.EventOFPPacketIn,MAIN_DISPATCHER)
	def deal_Arp(self, ev):
		msg = ev.msg
		dpid = msg.datapath
		ofp = dpid.ofproto
		ofp_parser = dpid.ofproto_parser

		pkt = Packet(msg.data)


		#deal - arp
		if(len(pkt.protocols) >= 2 and
			str!=type(pkt.protocols[0]) and 
			str!=type(pkt.protocols[1])):

			if("arp" == pkt.protocols[1].protocol_name):

				#print "\n==========================\n"
				#print pkt
				action = [ofp_parser.OFPActionOutput(ofp.OFPP_FLOOD)]
				out = ofp_parser.OFPPacketOut(datapath = dpid,
												buffer_id = msg.buffer_id,
												in_port = msg.in_port,
												actions = action)
				dpid.send_msg(out)
				#print "Arp Go"
					

		#deal - ipv4 - ping
		if(len(pkt.protocols) >= 3 and
			str!=type(pkt.protocols[0]) and 
			str!=type(pkt.protocols[1]) and 
			str!=type(pkt.protocols[2])):

			if("ipv4" == pkt.protocols[1].protocol_name): 

				if("icmp" == pkt.protocols[2].protocol_name):

					#print "\n==========================\n"
					#print pkt

					ipSrc = pkt.protocols[1].src
					ipDst = pkt.protocols[1].dst

					Match = ofp_parser.OFPMatch(
											dl_type = 0x0800,
											nw_src = ipv4_text_to_int(ipSrc),
											nw_dst = ipv4_text_to_int(ipDst)
											)

					Action = [ofp_parser.OFPActionOutput(ofp.OFPP_NORMAL)]

					out = ofp_parser.OFPFlowMod(datapath = dpid,
													match = Match,
													cookie = 0,
													command = ofp.OFPFC_ADD,
													idle_timeout = 10,
													hard_timeout = 10,
													buffer_id = msg.buffer_id,
													actions = Action)
					dpid.send_msg(out)
					#print "ICMP Go"

					# UP - forward, DOWN - backward

					Match = ofp_parser.OFPMatch(
											dl_type = 0x0800,
											nw_src = ipv4_text_to_int(ipDst),
											nw_dst = ipv4_text_to_int(ipSrc)
											)

					Action = [ofp_parser.OFPActionOutput(ofp.OFPP_NORMAL)]

					out = ofp_parser.OFPFlowMod(datapath = dpid,
													match = Match,
													cookie = 0,
													command = ofp.OFPFC_ADD,
													idle_timeout = 10,
													hard_timeout = 10,
													buffer_id = msg.buffer_id,
													actions = Action)
					dpid.send_msg(out)
					#print "ICMP backward"

				elif("tcp" == pkt.protocols[2].protocol_name):

					tcpSrc = pkt.protocols[2].src_port
					tcpDst = pkt.protocols[2].dst_port
					if(80 == tcpDst):

						ipSrc = pkt.protocols[1].src
						ipDst = pkt.protocols[1].dst

						if(len(pkt.protocols) >= 4):

							if(time.time() - self.oldT < 5 and time.time() - self.oldT > 0.3): # 0.3 is compatible with normal resent because of normal delay

								# block visit web request

								#print "\n========== Ban ===========\n"								
								#print self.oldT
								#print time.time()

								ethTo = pkt.protocols[0]
								ipTo = pkt.protocols[1]
								tcpTo = pkt.protocols[2]
								

								ethBan = ethernet(src = ethTo.dst,
												dst = ethTo.src,
												ethertype = ETH_TYPE_IP
												)
								ipBan = ipv4(src = ipTo.dst,
											dst = ipTo.src,
											proto = 6
												)

								#httpBan = "HTTP/1.1 302 Moved Temporarily\r\nServer: DrcomServer1.0\r\nLocation: http://16.211.108.227\r\nCache-Control: no-cache\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
								httpBan = "HTTP/1.1 200 OK\r\nContent-Length: 257\r\nContent-Type: text/html; charset=utf-8\r\n\r\n<html><head><title>BigMao Radio Station</title></head><body>BigMao Radio Station </br></br> You don't have the permission to Load this Web.</br></br>Your access has been blocked by Ryu. Please contact Network Administrator at +86-152-0366-2016</body></html>"


								# Attention ! HTTP protocol + before(eth,ipv4,tcp),the total size is larger than 128 !!! Switch packet-in is not enough to calculate Ack! My God! I forgot it !
								tcpAck = tcpTo.seq#+tcpTo.__len__()+len(pkt.protocols[3])
								# TODO - OFPSwitchFeature
								# TODO - advance tcpAck!

								# print pkt.protocols[3]
								# print len(pkt.protocols[3])
								# print tcpTo.__len__()
								# print tcpTo.seq
								# print tcpAck
								# print pkt
								tcpSeq = tcpTo.ack
								tcpBan = tcp(src_port = tcpTo.dst_port,
											dst_port = tcpTo.src_port,
											ack = tcpAck, 
											seq = tcpSeq,
											bits = 0x018, # or 0x018 0x019    RST_TCP: 0x01c
											window_size = 57, # or 29184
											)


								httpBanPkt = Packet()
								httpBanPkt.add_protocol(ethBan)
								httpBanPkt.add_protocol(ipBan)
								httpBanPkt.add_protocol(tcpBan)
								httpBanPkt.add_protocol(httpBan)
								httpBanPkt.serialize()

								Action = [ofp_parser.OFPActionOutput(ofp.OFPP_NORMAL)]

								out1 = ofp_parser.OFPPacketOut(datapath = dpid,
																in_port = ofp.OFPP_CONTROLLER,
																buffer_id = ofp.OFP_NO_BUFFER,
																data = httpBanPkt.data,
																actions = Action)
								
								# UP - block visit web request HTTP contect    DOWN - RST TCP connection

								"""
								tcpRST = tcp(src_port = tcpTo.dst_port,
											dst_port = tcpTo.src_port,
											ack = tcpAck+105,
											seq = tcpSeq,
											bits = 0x004, # or 0x018 0x019    RST_TCP: 0x01c
											window_size = 0 # or 29184
											)

								httpRST = Packet()
								httpRST.add_protocol(ethBan)
								httpRST.add_protocol(ipBan)
								httpRST.add_protocol(tcpRST)
								httpRST.serialize()

								Action = [ofp_parser.OFPActionOutput(ofp.OFPP_NORMAL)]

								out2 = ofp_parser.OFPPacketOut(datapath = dpid,
																in_port = ofp.OFPP_CONTROLLER,
																buffer_id = ofp.OFP_NO_BUFFER,
																data = httpRST.data,
																actions = Action)
								
								dpid.send_msg(out1)
								print "HTTP Ban Web"
								dpid.send_msg(out2)
								print "TCP RST"
								"""

								
								dpid.send_msg(out1)
								#print "HTTP Ban Web"

								# tell switch drop the buffer, is this indispensable?
								ActionDrop = []
							
								out4 = ofp_parser.OFPPacketOut(datapath = dpid,
																in_port = msg.in_port,
																buffer_id = msg.buffer_id,
																actions = ActionDrop)
								dpid.send_msg(out4)
								#print "Switch Drop Packet"

								#print "*** 80 Send HTTP Ban ***"
								#print httpBanPkt
								#print "*** 80 Send TCP RST ***"
								#print httpRST

							else:

								# allow visit web request

								Action = [ofp_parser.OFPActionOutput(ofp.OFPP_NORMAL)]

								out4 = ofp_parser.OFPPacketOut(datapath = dpid,
																buffer_id = msg.buffer_id,
																in_port = msg.in_port,
																actions = Action)

								dpid.send_msg(out4)
								#print "HTTP Request Permit"

								#print pkt
								#print "\n========== Go ===========\n"	
								#print self.oldT
								#print time.time()
								self.oldT = time.time()
								

							
							# Allow backward ,but filter forward - to allow TCP handshake but to ban HTTP request transmitting

							Match = ofp_parser.OFPMatch(
													dl_type = 0x0800,
													nw_src = ipv4_text_to_int(ipDst),
													nw_dst = ipv4_text_to_int(ipSrc),
													nw_proto = 6,
													tp_dst = tcpSrc
													)

							out3 = ofp_parser.OFPFlowMod(datapath = dpid,
															match = Match,
															cookie = 0,
															command = ofp.OFPFC_ADD,
															idle_timeout = 3,
															hard_timeout = 3,
															actions = Action)
							
							dpid.send_msg(out3)
							#print "HTTP backward"


						else :
							# TCP handshake / goodbye / other  packet

							ActionOut = [ofp_parser.OFPActionOutput(ofp.OFPP_NORMAL)]
							

							out1 = ofp_parser.OFPPacketOut(datapath = dpid,
															in_port = msg.in_port,
															buffer_id = msg.buffer_id,
															actions = ActionOut)


							Match = ofp_parser.OFPMatch(
													dl_type = 0x0800,
													nw_src = ipv4_text_to_int(ipDst),
													nw_dst = ipv4_text_to_int(ipSrc),
													nw_proto = 6,
													tp_dst = tcpDst
													)

							ActionMatch = [ofp_parser.OFPActionOutput(ofp.OFPP_CONTROLLER)]

							out2 = ofp_parser.OFPFlowMod(datapath = dpid,
															match = Match,
															cookie = 0,
															command = ofp.OFPFC_ADD,
															idle_timeout = 3,
															hard_timeout = 3,
															buffer_id = msg.buffer_id,
															actions = ActionMatch)

							
							dpid.send_msg(out1)
							#print "TCP control Go"
							dpid.send_msg(out2)
							#print "TCP control backward"

							#print "\n==========================\n"
							#print "*** 80 Handshake Go ***"
							#print pkt
					else:
						
						#Allow other app to telecommunicate

						ipSrc = pkt.protocols[1].src
						ipDst = pkt.protocols[1].dst

						Match = ofp_parser.OFPMatch(
												dl_type = 0x0800,
												nw_src = ipv4_text_to_int(ipSrc),
												nw_dst = ipv4_text_to_int(ipDst),
												nw_proto = 6,
												tp_dst = tcpDst
												)

						Action = [ofp_parser.OFPActionOutput(ofp.OFPP_NORMAL)]

						out = ofp_parser.OFPFlowMod(datapath = dpid,
														match = Match,
														cookie = 0,
														command = ofp.OFPFC_ADD,
														idle_timeout = 5,
														hard_timeout = 5,
														buffer_id = msg.buffer_id,
														actions = Action)
						dpid.send_msg(out)
						#print "allow other app"

						# print "\n==========================\n"
						# print "*** 80 Backward Go ***"
						# print pkt
						


				elif (True):
					#print "\n=========Unknown=========\n"
					#print pkt
					pass



def ipv4_text_to_int(ip_text):
    if ip_text == 0:
        return ip_text
    assert isinstance(ip_text, str)
    return struct.unpack('!I', addrconv.ipv4.text_to_bin(ip_text))[0]