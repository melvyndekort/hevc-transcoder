#!/bin/bash

rsync -a /nextcloud/melvyndekort/files/InstantUpload/Camera/ /photos/melvyn/
rsync -a /nextcloud/kaatjeislief/files/InstantUpload/Camera/ /photos/karin/
rsync -a /nextcloud/daandekort/files/InstantUpload/Camera/ /photos/daan/

shopt -s globstar
for INPUT in /photos/**/*.mp4; do
  [[ "$INPUT" = *"-hevc.mp4" ]] && continue

  OUTPUT="$(echo $INPUT | sed 's/.mp4$/-hevc.mp4/')"
  [ -f "$OUTPUT" ] && continue

  echo "Starting conversion: $INPUT -> $OUTPUT"
  ffmpeg -i "$INPUT" -c:v libx265 -crf 26 -preset fast -c:a copy "$OUTPUT"
  [ "$?" -ne 0 ] && rm -f "$OUTPUT" && echo "Something went wrong" && exit 1
  touch -r "$INPUT" "$OUTPUT"

  INDUR="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 """$INPUT""" | cut -d. -f1)"
  OUTDUR="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 """$OUTPUT""" | cut -d. -f1)"
  case "$(($INDUR-$OUTDUR))" in
    -1) rm -f "$INPUT"; echo "Finished conversion: $INPUT -> $OUTPUT" ;;
    0)  rm -f "$INPUT"; echo "Finished conversion: $INPUT -> $OUTPUT" ;;
    1)  rm -f "$INPUT"; echo "Finished conversion: $INPUT -> $OUTPUT" ;;
    *)  rm -f "$OUTPUT"; echo "ERROR: Something went wrong!"; exit 1 ;;
  esac

done
