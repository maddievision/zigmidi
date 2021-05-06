const std = @import("std");

pub const SynthError = error{
    InvalidTypeError,
};

pub fn noteToFreq(octaveBase: u16, intervals: u8, baseFreq: f32, offset: f32) f32 {
    return baseFreq * std.math.pow(f32, @intToFloat(f32, octaveBase), offset / @intToFloat(f32, intervals));
}

pub fn midiNoteToFreq(comptime T: type, note: T, baseFreq: f32, baseNote: T) SynthError!f32 {
    const offset = switch(T) {
        u8, u16, u32 => @intToFloat(f32, note - baseNote),
        f16, f32 => note - baseNote,
        else => { return .InvalidTypeError; }
    };

    return noteToFreq(2, 12, baseFreq, offset);
}

pub fn midiNoteToFreqBasic(comptime T: type, note: T) SynthError!f32 {
    const baseNote = switch(T) {
        u8, u16, u32 => 69,
        f16, f32 => 69.0,
        else => { return .InvalidTypeError; }
    };

    return try midiNoteToFreq(T, note, 440.0, baseNote);
}
