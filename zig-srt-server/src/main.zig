const std = @import("std");
const net = std.net;
const c = @cImport({
    @cInclude("srt/srt.h");
});

const bufSize: i32 = 1316;

pub fn main() !void {
    if (c.srt_startup() == -1) {
        @panic("Failed to startup srt\n");
    }
    defer _ = c.srt_cleanup();

    const in_sock = c.srt_create_socket();
    if(in_sock == c.SRT_INVALID_SOCK){
        @panic("Failed to create socket");
    }
    defer _ = c.srt_close(in_sock);
    const in_addr: net.Address = net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, 4201);
    var in_sock_bind: std.c.sockaddr = in_addr.any;
    
    if (c.srt_connect(in_sock, @as(*c.sockaddr, @ptrCast(&in_sock_bind)), @sizeOf(std.c.sockaddr)) == -1) {
        @panic("Failed to connect to the server");
    }

    

    var bufet: [bufSize]u8 = undefined;
    var ret = c.srt_recv(in_sock, &bufet, bufSize);
    while(ret != 0){
         if (ret == -1) {
             std.debug.print("Failed to recieve message with error {s}\n", .{c.srt_getlasterror_str()});
         } else {
            std.debug.print("message recieved with NO errors\nMessage: {s}\n", .{bufet});
            //print_message(&bufet);
         }
         ret = c.srt_recvmsg(in_sock, &bufet, bufSize);
    } 
   
}


fn print_message(buffer: []u8) void{
    for(0..buffer.len) |i| {
        if(buffer[i] == 0){
            std.debug.print("end of string\n", .{});
        } else {
            std.debug.print("{c}", .{buffer[i]});
        }
    }
}
