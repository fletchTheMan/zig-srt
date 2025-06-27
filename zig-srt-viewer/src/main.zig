const std = @import("std");
const net = std.net;
const c = @cImport({
    @cInclude("srt/srt.h");
    @cInclude("libavformat/avformat.h");
    @cInclude("libavcodec/avcodec.h");
});

const bufSize: i32 = 1316;
pub fn main() !void {
    if (c.srt_startup() == -1) {
        @panic("Failed to startup srt\n");
    }
    defer _ = c.srt_cleanup();

    const srt_sock: c.SRTSOCKET = c.srt_create_socket();
    if(srt_sock == c.SRT_INVALID_SOCK){
        @panic("Failed to create srt socket");
    }
    defer _ = c.srt_close(srt_sock);

    const addr: net.Address = net.Address.initIp4([4]u8{127, 0, 0, 1}, 4201);
    var sock_bind: std.c.sockaddr = addr.any;
    if(c.srt_connect(srt_sock, @as(*c.sockaddr, @ptrCast(&sock_bind)), @sizeOf(std.c.sockaddr)) == -1){
        @panic("Failed to connect to the server\n");
    }

    var bufet: [bufSize]u8 = undefined;
    var ret = c.srt_recvmsg(srt_sock, &bufet, bufSize);
    while(ret != 0){
        if(ret == -1){
            std.debug.print("Failed to recieve message with errors {s}\n", .{c.srt_getlasterror_str()});
        }
        else {
            std.debug.print("recieved message with no errors\n", .{});
            
        }
        ret = c.srt_recvmsg(srt_sock, &bufet, bufSize);
    }
}

//fn decodeBuf(bufet: [bufSize]u8) !void{}
