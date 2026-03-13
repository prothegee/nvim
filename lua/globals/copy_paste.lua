_G.copy_file = function(src, dst)
    vim.schedule(function()
        local _uv = vim.uv

        local src_fd, open_err = _uv.fs_open(src, "r", 420) -- 420 = 0o644
        if not src_fd then
            vim.notify("fail to open source file: " .. open_err, vim.log.levels.ERROR)
            return
        end

        local stat, stat_err = _uv.fs_fstat(src_fd)
        if not stat then
            _uv.fs_close(src_fd)
            vim.notify("fail to read file metadata: " .. stat_err, vim.log.levels.ERROR)
            return
        end

        local dst_fd, create_err = _uv.fs_open(dst, "w", 420)
        if not dst_fd then
            _uv.fs_close(src_fd)
            vim.notify("fail to create file destination: " .. create_err, vim.log.levels.ERROR)
            return
        end

        local buf = _uv.fs_read(src_fd, stat.size, 0)
        if not buf then
            _uv.fs_close(src_fd)
            _uv.fs_close(dst_fd)
            vim.notify("failed to read file", vim.log.levels.ERROR)
            return
        end

        local written = _uv.fs_write(dst_fd, buf, 0)
        if not written or written ~= #buf then
            vim.notify("fail to write file", vim.log.levels.WARN)
        end

        _uv.fs_close(src_fd)
        _uv.fs_close(dst_fd)
    end)
end
