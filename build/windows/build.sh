#!/usr/bin/env sh

ocran run.rb --output lsp.exe --add-all-core --gemfile ./Gemfile --no-dep-run --gem-full --gem-full=platformos-check --console \
--gem-file /c/Ruby32-x64/bin/etc/ssl \
--dll ruby_builtin_dlls/libyaml-0-2.dll \
--dll ruby_builtin_dlls/zlib1.dll \
--dll ruby_builtin_dlls/libssl-3-x64.dll \
--dll ruby_builtin_dlls/libcrypto-3-x64.dll \
--dll ruby_builtin_dlls/libgmp-10.dll \
--dll ruby_builtin_dlls/libyaml-0-2.dll \
--dll ruby_builtin_dlls/libffi-8.dll \
--dll ruby_builtin_dlls/libssl-3-x64.dll \
--dll ruby_builtin_dlls/libgcc_s_seh-1.dll \
--dll ruby_builtin_dlls/libwinpthread-1.dll \
--dll ruby_builtin_dlls/zlib1.dll

echo 'finished'
ls
