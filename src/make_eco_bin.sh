make dump_eco
make extend_eco
./extend_eco data/eco.orig > /tmp/eco.txt
./dump_eco /tmp/eco.txt > /tmp/eco.bin
mv /tmp/eco.bin data/eco.bin
