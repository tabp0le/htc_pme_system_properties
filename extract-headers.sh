#!/bin/sh

mkdir -p headers

for i in $*
do
   echo "Starting $i"
   name=`basename $i | sed 's/-.*//'`
   cidlist=`grep cidlist= $i | cut -d '=' -f 2 | sed 's/,/ /g'`
   sku=`grep ro.build.sku= $i | cut -d '=' -f 2`
   (
      echo "/* $i: $sku: $cidlist */"
      echo "static bool is_variant_$name(std::string bootcid) {"
      for cid in $cidlist
      do
	echo '    if (HAS_SUBSTRING(bootcid, "'$cid'")) return true;'
      done
      echo "    return false;"
      echo "}"
      echo
      echo "static const char *htc_"$name"_properties = "
      (
	grep ^ro.build.fingerprint $i
	grep ^ro.build.product $i
	grep ^ro.product.device $i
	egrep '^[^#].*(radio|ril|telephony|gsm|cdma)' $i | \
	    egrep -v ^rild.libpath=
      ) | sed 's/.*/"&\\n"/'
      echo ";"
   ) > headers/htc-"$name".h
done
