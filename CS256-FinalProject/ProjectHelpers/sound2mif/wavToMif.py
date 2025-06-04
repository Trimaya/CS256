import sys
import struct

# error helper
def err(msg):
	print msg
	exit(1)

# check args
if len(sys.argv) != 3:
	err("Usage: python wavToMif.py <input.wav> <output.mif>")

f_in = sys.argv[1]
f_out = sys.argv[2]

out = []

# read input file
with open(f_in, 'rb') as f:
	# read RIFF
	byte_arr = f.read(4)
	if byte_arr != "RIFF":
		err("Incorrect format 1")

	f.read(4) # read chunksize

	# read WAVE
	byte_arr = f.read(4)
	if byte_arr != "WAVE":
		err("Incorrect format 2")

	f.read(24) # read 24 more bytes to get to data

	# read data
	byte_arr = f.read(4)
	if byte_arr != "data":
		err("Incorrect format 3")

	f.read(4) # read past file size

	# read data
	while 1:
		byte_arr = f.read(2) # read in 16b chunks
		if not byte_arr:
			break
		out.append(byte_arr)

with open(f_out, 'wb') as f:
	#  print headers
	f.write("DEPTH = %d;\nWIDTH = 16;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n" % len(out))

	for i in range(len(out)):
		addr = hex(i).upper()[2:]
		value = hex(struct.unpack('<H', out[i])[0]).upper()[2:]
		value = value.zfill(4) # zero pad
		f.write("\n%s : %s;" % (addr, value))

	f.write("\n\nEND;")
