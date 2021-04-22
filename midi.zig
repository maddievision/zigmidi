const std = @import("std");
const Writer = std.fs.File.Writer;

pub fn writeVarLength(fwriter: Writer, value: u32) !void {
    var val: u32 = value;
    const x: u32 = 0x7F;
    const y: u32 = 0x80;

    while (true) {
        const byte: u8 = @intCast(u8, (val & x) + if (val > x) y else 0);
        val >>= 7;
        try fwriter.writeByte(byte);
        if (val == 0) break;
    }
}

pub fn writeMidiHeader(fwriter: Writer, format: u16, trackCount: u16, ppqn: u16) !void {
    try fwriter.print("MThd", .{});
    try fwriter.writeIntBig(u32, 6); // header size
    try fwriter.writeIntBig(u16, format);
    try fwriter.writeIntBig(u16, trackCount);
    try fwriter.writeIntBig(u16, ppqn);
}

pub fn writeTrackHeader(fwriter: Writer) !u64 {
    try fwriter.print("MTrk", .{});
    const trackSizePos = try fwriter.context.getPos();
    try fwriter.writeIntBig(u32, 0); // placeholder track size
    return trackSizePos + 4; // track start
}

pub fn writeEndOfTrack(fwriter: Writer, trackPos: u64) !void {
    // eot
    try writeVarLength(fwriter, 0); // delta
    try fwriter.writeByte(0xFF); // meta
    try fwriter.writeByte(0x2F); // eot
    try fwriter.writeByte(0); // event length

    // write track length
    const currentPos = try fwriter.context.getPos();
    const trackLength = currentPos - trackPos;
    try fwriter.context.seekTo(trackPos - 4);
    try fwriter.writeIntBig(u32, @intCast(u32, trackLength));
    try fwriter.context.seekTo(currentPos);
}

pub fn writeTempoEvent(fwriter: Writer, tempo: f32) !void {
    try writeVarLength(fwriter, 0); // delta
    try fwriter.writeByte(0xFF); // meta
    try fwriter.writeByte(0x51); // tempo
    try fwriter.writeByte(3); // event length
    const tempomspt = @floatToInt(u24, 60_000_000.0 / tempo);
    try fwriter.writeIntBig(u24, tempomspt);
}

pub fn writeNoteOn(fwriter: Writer, delta: u32, channel: u8, note: u8, velocity: u8) !void {
    try writeVarLength(fwriter, delta);
    try fwriter.writeByte(0x90 + channel);
    try fwriter.writeByte(note);
    try fwriter.writeByte(velocity);
}

pub fn writeNoteOff(fwriter: Writer, delta: u32, channel: u8, note: u8, velocity: u8) !void {
    try writeVarLength(fwriter, delta);
    try fwriter.writeByte(0x80 + channel);
    try fwriter.writeByte(note);
    try fwriter.writeByte(velocity);
}

pub fn writeNote(fwriter: Writer, delta: u32, channel: u8, note: u8, velocity: u8, length: u32, offVelocity: u8) !void {
    try writeNoteOn(fwriter, delta, channel, note, velocity);
    try writeNoteOff(fwriter, length, channel, note, offVelocity);
}