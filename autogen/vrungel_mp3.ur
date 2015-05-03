open Vrungel_mp3_c
fun content {} = b <- blob () ; returnBlob b (blessMime "audio/mpeg")
val propagated_urls : list url = 
    []
val url = url(content {})
val geturl = url
