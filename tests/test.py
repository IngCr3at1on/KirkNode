#!/usr/bin/env python3

'''Simple protocol test to confirm connect and basic JSON recognition,
	courtesy of Ricardo G.'''

import socket
import json
import threading
from collections import deque
import time

CHUNK_SIZE = 640

def pushback_socket(sock, lock=None):
	'''Implements a function that can read
	and another to push back data to be read again'''
	bufsize = 4096
	buf = deque([])
	if not lock:
		lock = threading.Lock()
	def read(amt=1):
		with lock:
			try:
				d = sock.recv(bufsize)
				buf.extend(d)
			except Exception:
				pass
		if len(buf) >= amt:
			return bytes(buf.popleft() for i in range(amt))
	def pushback(data):
		with lock:
			buf.extendleft(reversed(data))
		return data
	return (read, pushback, lock)

		
def open_socket(host, port):
	'''Opens a socket over ipv4 to `host` at `port`
	Returns a dictionary of the input, output and the socket'''
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.connect((host, port))
	f = sock.makefile()
	sock.setblocking(0) #TODO: Make this an option
	read, unread, lock = pushback_socket(sock)
	def write(data):
		with lock:
			sock.send(data)

	return {'socket': sock,
			'lock': lock,
			'read': read,
			'unread': unread,
                        'write': write}

def read_json(jim):
	'''Returns the next json object from the `jim`'''
	read = jim['read']
	unread = jim['unread']
	i = CHUNK_SIZE
	s = read(i)
	while not s:
		if i < 2:
			return
		s = read(i)
		i -= 1
	data = s.decode('UTF-8')
	while len(data) > 0:
		print(data)
		try:
			return json.loads(data)
		except Exception as e:
			unread(data[-1:])
			data = data[:-1]

def write_json(jim, obj):
	'''writes an object as json to the `jim`'''
	jim['write'](json.dumps(obj).encode('UTF-8'))

if __name__ == '__main__':
	jim = open_socket('127.0.0.1', 4004)
	print(read_json(jim))
	write_json(jim, {'action': 'quit'})
