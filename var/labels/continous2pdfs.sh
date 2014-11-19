#!/bin/bash

# --------------------------------------------------------------------------- #
#                                                                             #
#  Copyright (C) 2014 LAFKON/Christoph Haag                                   #
#                                                                             #
#  XXX is free software: you can redistribute it      # 
#  and/or modify it under the terms of the GNU General Public License as      # 
#  published by the Free Software Foundation, either version 3,               #
#  or (at your option) any later version.                                     #
#                                                                             #
#  XXX is distributed in the hope that it             #
#  will be useful, but WITHOUT ANY WARRANTY; without even the implied         #
#  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.           #
#  See the GNU General Public License for more details.                       #
#                                                                             #
# --------------------------------------------------------------------------- #

  SVG=$1
# PDF=${SVG%%.*}.pdf
  OUTDIR=___
  BASENAME=`echo ${SVG%%.*} | rev | cut -d "-" -f 1 | rev`

  echo $OUTDIR/${BASENAME}

# --------------------------------------------------------------------------- #
# INTERACTIVE CHECKS 
# --------------------------------------------------------------------------- #
  if [ ! -f ${SVG%%.*}.svg ]; then echo; echo "We need a svg!"
                                         echo "e.g. $0 yoursvg.svg"; echo
      exit 0;
  fi
  if [ `ls $OUTDIR/${BASENAME}-* | wc -l` -gt 0 ]; then
       echo "export for $SVG does exist!"
       read -p "overwrite $OUTDIR/${BASENAME}-XX? [y/n] " ANSWER
       if [ $ANSWER != y ] ; then echo "Bye"; exit 0; fi
  fi


# --------------------------------------------------------------------------- #
# MOVE ALL LAYERS ON SEPARATE LINES IN A TMP FILE
# --------------------------------------------------------------------------- #
  sed ':a;N;$!ba;s/\n/ /g' $SVG          | # REMOVE ALL LINEBREAKS
  sed 's/<g/4Fgt7RfjIoPg7/g'             | # PLACEHOLDER FOR GROUP OPEN
  sed 's/4Fgt7RfjIoPg7/\n<g/g'           | # RESTORE GROUP OPEN + NEWLINE
  sed '/groupmode="layer"/s/<g/4Fgt7R/g' | # PLACEHOLDER FOR LAYERGROUP OPEN
  sed ':a;N;$!ba;s/\n/ /g'               | # REMOVE ALL LINEBREAKS
  sed 's/4Fgt7R/\n<g/g'                  | # RESTORE LAYERGROUP OPEN + NEWLINE
  sed 's/display:none/display:inline/g'  | # MAKE VISIBLE EVEN WHEN HIDDEN
  grep -v 'label="XX_'                   | # REMOVE EXCLUDED LAYERS
  sed 's/<\/svg>/\n&/g'                  | # CLOSE TAG ON SEPARATE LINE
  tr -s ' '                              | # CLEAN CONSECUTIVE SPACES
  tee > ${SVG%%.*}.tmp                     # WRITE TO TEMPORARY FILE

# --------------------------------------------------------------------------- #
# SHIFT CONTNENT AND EXPORT PDF FILES 
# --------------------------------------------------------------------------- #

  CNT=100
  SHIFTSUM=0

  SVGHEADER=`head -n 1 ${SVG%%.*}.tmp`

  while [ $CNT -lt 120 ];
   do
       PDF=$OUTDIR/${BASENAME}-${CNT}.pdf

       if [ `expr $CNT \/ 2 \* 2` != $CNT ]; then

             SHIFTADD=1764
       else
             SHIFTADD=1431
       fi

       TRANSFORM="transform=\"translate(-${SHIFTSUM},0)\""

       echo $SVGHEADER              >  tmp.svg
       echo "<g $TRANSFORM inkscape:label=\"ALL\">"       >> tmp.svg  
       grep "^<g" ${SVG%%.*}.tmp    >> tmp.svg
       echo "</g>"                  >> tmp.svg
       echo "</svg>"                >> tmp.svg
       
       inkscape --export-pdf=$PDF \
                tmp.svg

       SHIFTSUM=`expr $SHIFTSUM + $SHIFTADD`
       CNT=`expr $CNT + 1`

  done



  rm ${SVG%%.*}.tmp tmp.svg


exit 0;
