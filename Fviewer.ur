val srcprj = bless "https://github.com/grwlf/urweb-fviewer"

fun template mb : transaction page =
  let
  Uru.run (
  JQuery.add (
  Bootstrap.add (
  Soup.narrow (fn nar =>
  Uru.withHeader
  <xml>
    <title>Upload file</title>
    (* <link rel="icon" type="image/x-icon" href={Favicon_ico.geturl}/> *)
  </xml> (
  Uru.withBody (fn _ =>
    b <- XMLW.run mb;
    return
    <xml>
      {nar.Container
      <xml>
        {Soup.forkme_ribbon srcprj}
        <div style="text-align:center">
          {b}
        </div>
      </xml>}

      {nar.Footer
      <xml>
        <hr/>
        <p class={Bootstrap.text_muted}>
          The site is written in <a href={bless "http://impredicative.com/ur/"}>Ur/Web</a>,
          the general-purpose typed functional language.
        </p>
        <p class={Bootstrap.text_muted}>
        <ul style="padding-left: 0px; margin-top: 20px; color: #999;">
          {Soup.footer_doc_links (
          <xml><a href={srcprj}>Sources</a></xml> ::
          <xml><a href={bless "http://github.com/grwlf/cake3"}>Cake3</a></xml> ::
          <xml><a href={bless "http://github.com/grwlf/uru3"}>Uru3</a></xml> ::
          <xml><a href={bless "http://github.com/grwlf/urweb-monad-pack"}>MonadPack</a></xml> ::
          <xml><a href={bless "http://github.com/grwlf/urweb-xmlw"}>XMLW</a></xml> ::
          <xml><a href={bless "http://github.com/grwlf/urweb-soup"}>Soup</a></xml> ::
          []
          )}
        </ul>
        </p>
      </xml>}

    </xml>

    ))))))
  where
  end

fun xtabl m =
  XMLW.push_back (XMLW.nest (fn x=><xml><table class={
    CSS.list (Bootstrap.bs3_table :: Bootstrap.table_striped :: [])}>{x}</table></xml>) m)
fun xdiv cls st m =
  XMLW.push_back (XMLW.nest (fn x=><xml><div class={cls} style={st}>{x}</div></xml>) m)
fun xp  m =
  XMLW.push_back (XMLW.nest (fn x=><xml><p>{x}</p></xml>) m)
val xrow = xdiv Bootstrap.row (STYLE "")
val xcol1 = xdiv Bootstrap.col_md_12 (STYLE "")
val xcol2 = xdiv Bootstrap.col_md_6 (STYLE "")
val pb = @@XMLW.push_back_xml


cookie auth : string
sequence auth_seq

fun with_auth_cookie [x:::Type] (f : string -> transaction x) : transaction x =
  c <- getCookie auth;
  u <- (case c of
    |None =>
      u <- ((fn x => "User-" ^ (show x)) `Prelude.ap` nextval auth_seq);
      setCookie auth {Value=u, Expires=None, Secure=False};
      debug("Set auth cookie: " ^ (show u));
      return u
    |Some u =>
      debug("Picked up auth cookie: " ^ u);
      return u);
  f u

sequence files_seq
table files : {Id:int, User: string, File:blob, Size:int, Nam:string, MimeType:string}
  PRIMARY KEY Id

val user_size_limit = 10 * 1024 * 1024
val global_size_limit = 100 * 1024 * 1024

fun insert_ (u:string) (f:file) : transaction (option int) =
  let 
    val fsz = blobSize (fileData f)
    val mt = fileMimeType f
  in
  sz <- ((Option.get 0) `Prelude.ap` oneRowE1(SELECT SUM(F.Size) FROM files AS F WHERE F.User = {[u]}));
  if (sz + fsz) > user_size_limit then
    return None
  else (
    sz <- ((Option.get 0) `Prelude.ap` oneRowE1(SELECT SUM(F.Size) FROM files AS F));
    if (sz + fsz) > global_size_limit then
      return None
    else (
      i <- nextval files_seq;
      fnm <- return (case fileName f of |Some n => n | None => "file_"^(show i));
      dml(INSERT INTO files(Id,User,File,Size,Nam,MimeType)
          VALUES  ({[i]}, {[u]}, {[fileData f]}, {[fsz]}, {[fnm]}, {[mt]}));
      return (Some i)
    )
  )
  end

fun delete_ (id:int) : transaction unit =
  dml(DELETE FROM files WHERE Id = {[id]})

fun receive (f:{File:file}) : transaction page =
  with_auth_cookie (fn u =>
  template (
    (case (fileData f.File |> blobSize) > 0 of
      |True =>
        ok <- XMLW.lift( insert_ u f.File );
        (case ok of
          |Some id => pb
            <xml>
              <p>File size: {[
                 fileData f.File |>
                 blobSize |>
                 (fn x => Soup.fmtfloat 2 ((float x) / (1024.0 * 1024.0) ))
              ]} Mb </p>
              <p>You will be redirected to the main page in a few seconds.</p>
              <active code={ spawn(sleep (5*1000); redirect (url (main{}))); return <xml/> }/>
            </xml>
          |None => pb
            <xml>Unable to upload file, size limits exceeded</xml>)
      |False => pb
        <xml>No file selected</xml>);

    pb <xml><p><a link={main {}}>Back</a></p></xml>
  ))

and main {} : transaction page = 
  template (
  pb <xml><h1>Uploader test</h1></xml>;

  xrow (
  xcol1 (

    xp (
    pb <xml><div style="text-align:left; margin-bottom:50px"><form>
      <div class={Bootstrap.form_group}>
        <label>File input</label>
        <upload{#File}/>
        <p class={Bootstrap.help_block}>Select PDF document to upload.</p>
      </div>
      <submit value="Add file" class={CSS.list (Bootstrap.btn :: Bootstrap.btn_default :: [])} action={receive}/>
    </form></div></xml>
    );

    xp(
    xtabl (
      pb
      <xml>
        <tr> <th>Id</th> <th>Cookie</th> <th>Name</th> <th>Type</th> <th>Size, Mb</th> <th/> </tr>
      </xml>;

      XMLW.query_ (SELECT F.Id, F.User, F.Nam, F.MimeType, F.Size FROM files AS F ORDER BY F.Id,F.User,F.Nam)
      (fn r =>
        pb
        <xml><tr>
          <td>{[r.F.Id]}</td>
          <td>{[r.F.User]}</td>
          <td>{[r.F.Nam]}</td>
          <td>{[r.F.MimeType]}</td>
          <td>{[
           Soup.fmtfloat 2 ((float r.F.Size) / (1024.0 * 1024.0) )
          ]}</td>
          <td>
            <button value="Delete" onclick={fn _=>
              rpc(delete_ r.F.Id);
              redirect(url(main {}))
            }/>
          </td>
        </tr></xml>
      )
    )
    )
  ))

  )

