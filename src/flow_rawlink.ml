open Lwt.Infix

type 'a io = 'a Lwt.t
type buffer = Cstruct.t
type error = [`Msg of string]
type write_error = [ Mirage_flow.write_error | error ]

let pp_error ppf (`Msg s) = Fmt.string ppf s

let pp_write_error ppf = function
  | #Mirage_flow.write_error as e -> Mirage_flow.pp_write_error ppf e
  | #error as e                   -> pp_error ppf e

type flow = Lwt_rawlink.t

let err e =  Lwt.return (Error (`Msg (Printexc.to_string e)))

let read t =
  Lwt.catch (fun () ->
      Lwt_rawlink.read_packet t >|= fun buf -> Ok (`Data buf)
    ) (function Failure _ -> Lwt.return (Ok `Eof) | e -> err e)

let write t b =
  Lwt.catch (fun () ->
      Lwt_rawlink.send_packet t b >|= fun () -> Ok ()
    ) (fun e  -> err e)

let close t = Lwt_rawlink.close_link t

let writev t bs =
  Lwt.catch (fun () ->
      Lwt_list.iter_s (Lwt_rawlink.send_packet t) bs >|= fun () -> Ok ()
    ) (fun e -> err e)
