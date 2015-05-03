module Cake_Fviewer where

import Development.Cake3
import Development.Cake3.Ext.UrWeb as UW
import qualified Cake_Bootstrap as Bootstrap hiding(main)
import qualified Cake_Prelude as Prelude hiding(main)
import qualified Cake_MonadPack as MonadPack hiding(main)
import qualified Cake_Soup as Soup hiding(main)
import qualified Cake_XMLW as XMLW hiding(main)
import Cake_Fviewer_P

(app,db) = uwapp_postgres (file "Fviewer.urp") $ do
  allow mime "text/javascript";
  allow mime "text/css";
  allow mime "image/jpeg";
  allow mime "image/png";
  allow mime "image/gif";
  allow mime "application/octet-stream";
  allow url "https://github.com/grwlf/urweb-fviewer*"
  library MonadPack.lib
  library Prelude.lib
  library Bootstrap.lib
  library Soup.lib
  library XMLW.lib
  embed (file "vrungel.mp3")
  ffi (file "Audio.urs")
  ur (sys "list")
  ur (sys "option")
  ur (sys "string")
  ur (sys "char")
  ur (file "Fviewer.ur")

main = writeDefaultMakefiles $ do

  rule $ do
    phony "dropdb"
    depend db

  rule $ do
    phony "all"
    depend app

