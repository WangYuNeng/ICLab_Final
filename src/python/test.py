import random as rm
import ecc
# if you want more prime to test, 
# go to "https://asecuritysite.com/encryption/random3?val=32"
def Hex(x, bit):
	x = hex(x)[2:].upper()
	if len(x) < bit//4:
		x = (bit//4-len(x))*"0" + x
	return x 

prime = {32  : (4274478947, 2529064183), \
         64  : (10253826458500797391, 11284165454174392817), \
         128 : (327399860224378664864061286270834374353, 302674824502929031312940705460922917239), \
         256 : (70890235173955024628095490721929126198401327691602974320904284799181343211259, 104111200161170617827237277984117166498040180790934578010809220117264536620149), \
        }

print("input bit length: (32, 64, 128, 256)")
bit = int(input())
print("input testcase: (0, 1)")
case = int(input())

infile = open("in" + str(bit) + "_" + str(case) + ".pattern", "w")
outfile = open("out" + str(bit) + "_" + str(case) + ".pattern", "w")

p = prime[bit][case]
a = rm.randint(pow(2,bit-1), p-1)
x = rm.randint(pow(2,bit-1), p-1)
y = rm.randint(pow(2,bit-1), p-1)
# y^2 = x^3 + ax + b
b = (pow(y,2,p) - pow(x,3,p) - (a*x)%p)%p

m = rm.randint(pow(2,bit-1), pow(2,bit))
n = rm.randint(pow(2,bit-1), pow(2,bit))

mP = ecc.ecc(p,a,b,x,y,m)
nP = ecc.ecc(p,a,b,x,y,n)
mnP = ecc.ecc(p,a,b,mP.x,mP.y,n)

infile.write("// testcase " + str(case) + " (" + str(bit) + ") (a,b,p,x,y,m,nP.x,nP.y)\n")
infile.write(Hex(a, bit)+"\n")
infile.write(Hex(b, bit)+"\n")
infile.write(Hex(p, bit)+"\n")
infile.write(Hex(x, bit)+"\n")
infile.write(Hex(y, bit)+"\n")
infile.write(Hex(m, bit)+"\n")
infile.write(Hex(nP.x, bit)+"\n")
infile.write(Hex(nP.y, bit)+"\n")

outfile.write("// golden " + str(case) + " (" + str(bit) + ") (mP.x,mP.y,mnP.x,mnP.y)\n")
outfile.write(Hex(mP.x, bit)+"\n")
outfile.write(Hex(mP.y, bit)+"\n")
outfile.write(Hex(mnP.x, bit)+"\n")
outfile.write(Hex(mnP.y, bit)+"\n")

infile.close()
outfile.close()
