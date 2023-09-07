FROM platformos/platformos-lsp:latest

ENTRYPOINT $WORKDIR/platformos-lsp/bin/platformos-check .
