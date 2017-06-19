## mirage-flow-rawlink -- Expose rawlink interfoaces as MirageOS flows

Allow to use rawlink interfaces as MirageOS flows.

For instance:

```ocaml
  Lwt_rawlink.open_link "eth0" >>= fun rawlink ->
  Mirage_flow_lwt.read rawlink >>= function
  | Ok (`Data buf) ->
  ...
```