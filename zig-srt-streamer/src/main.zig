const std = @import("std");
const net = std.net;
const c = @cImport({
    @cInclude("string.h");
    @cInclude("srt/srt.h");
});

const bufSize: i32 = 1316;

pub fn main() !void {
    const stdin = std.io.getStdIn(); if (c.srt_startup() == -1) {
        @panic("Failed to startup srt\n");
    }
    defer _ = c.srt_cleanup();

    const srt_sock: c.SRTSOCKET = c.srt_create_socket();
    if (srt_sock == c.SRT_INVALID_SOCK) {
        @panic("Failed to create socket");
    }
    defer _ = c.srt_close(srt_sock);

    const addr: net.Address = net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, 4201);
    var sock_bind: std.c.sockaddr = addr.any;
    if (c.srt_bind(srt_sock, @as(*c.sockaddr, @ptrCast(&sock_bind)), @sizeOf(std.c.sockaddr)) == -1) {
        @panic("Failed to bind the srt socket");
    }

    if (c.srt_listen(srt_sock, 15) == -1) {
        @panic("Failed to listen on the socket");
    }

    std.debug.print("listening at {d}\n", .{addr.in.getPort()});
    while (true) {
        var sock_size: i32 = @sizeOf(std.c.sockaddr);
        const client = c.srt_accept(srt_sock, @as(*c.struct_sockaddr, @ptrCast(&sock_bind)), &sock_size);

        var bufet: [bufSize]u8 = undefined;
        std.debug.print("Input: ", .{});
        var len = try stdin.read(&bufet);
        while(len != 0){
            const bufLength  = c.strnlen(&bufet, @as(c_int, bufSize));
            const ret = c.srt_sendmsg(client, &bufet, @as(c_int, bufLength), -1, 0) ;
            if (ret == -1) {
                std.debug.print("failed to send message with error {s}\n", .{c.srt_getlasterror_str()});
            } else {
                std.debug.print("sent message", .{});
            }
            std.debug.print("Input: ", .{});
            len = try stdin.read(&bufet);

        }
    }
}
