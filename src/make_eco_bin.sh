(cd db; make libdbstubs.a)
make dump_eco
make extend_eco
./extend_eco data/eco.orig > /tmp/eco.txt
./dump_eco /tmp/eco.txt > /tmp/eco.bin
cp /tmp/eco.bin data/eco.bin # don't use mv
rm /tmp/eco.bin
