const std = @import("std");
const midi = @import("./midi.zig");
const synth = @import("./synth.zig");
const Writer = std.fs.File.Writer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("hehe {d}hz", .{try synth.midiNoteToFreqBasic(u8, 72)});
    try stdout.print("hihi {d}hz", .{try synth.midiNoteToFreqBasic(f32, 72.5)});
    // try writeSampleMidiFile();
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
    defer try midi.writeEndOfTrack(fwriter, trackPos);

    try midi.writeTempoEvent(fwriter, tempo);

}

pub fn writeScaleTrack(fwriter: Writer) !void {
    const trackPos = try midi.writeTrackHeader(fwriter);
    defer try midi.writeEndOfTrack(fwriter, trackPos);

    const cMajorScale: [8]u8 = .{0x3C, 0x3E, 0x40, 0x41, 0x43, 0x45, 0x47, 0x48};
    inline for (cMajorScale) |note| {
        try midi.writeNote(fwriter, 0, 0, note, 0x7F, 96, 0);
    }
}

pub fn writeDrumTrack(fwriter: Writer) !void {
    const trackPos = try midi.writeTrackHeader(fwriter);
    defer try midi.writeEndOfTrack(fwriter, trackPos);

    const k: u8 = 36;
    const s: u8 = 40;
    const c: u8 = 49;

    const pattern: [8]u8 = .{k, k, s, k, k, k, s, c};
    inline for (pattern) |note| {
        try midi.writeNote(fwriter, 0, 9, note, 0x7F, 96, 0);
    }
}
