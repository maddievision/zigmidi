const std = @import("std");
const midi = @import("./midi.zig");
const Writer = std.fs.File.Writer;

pub fn main() !void {
    try writeSampleMidiFile();
}

pub fn writeSampleMidiFile() !void {
    const file = try std.fs.cwd().createFile("test.mid", .{});
    defer file.close();
    const fwriter = file.writer();

    try midi.writeMidiHeader(fwriter, 1, 3, 192);

    try writeTempoTrack(fwriter, 120.0);
    try writeScaleTrack(fwriter);
    try writeDrumTrack(fwriter);
}

pub fn writeTempoTrack(fwriter: Writer, tempo: f32) !void {
    const trackPos = try midi.writeTrackHeader(fwriter);

    try midi.writeTempoEvent(fwriter, tempo);

    try midi.writeEndOfTrack(fwriter, trackPos);
}

pub fn writeScaleTrack(fwriter: Writer) !void {
    const trackPos = try midi.writeTrackHeader(fwriter);

    const cMajorScale: [8]u8 = .{0x3C, 0x3E, 0x40, 0x41, 0x43, 0x45, 0x47, 0x48};
    inline for (cMajorScale) |note| {
        try midi.writeNote(fwriter, 0, 0, note, 0x7F, 96, 0);
    }

    try midi.writeEndOfTrack(fwriter, trackPos);
}

pub fn writeDrumTrack(fwriter: Writer) !void {
    const trackPos = try midi.writeTrackHeader(fwriter);

    const k: u8 = 36;
    const s: u8 = 40;
    const c: u8 = 49;

    const pattern: [8]u8 = .{k, k, s, k, k, k, s, c};
    inline for (pattern) |note| {
        try midi.writeNote(fwriter, 0, 9, note, 0x7F, 96, 0);
    }

    try midi.writeEndOfTrack(fwriter, trackPos);
}
