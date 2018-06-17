const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("msp430f5510-zig", "src/main.zig");
    exe.setBuildMode(mode);
    exe.setOutputPath("msp430f5510-zig");
    exe.setTarget(builtin.Arch.msp430, builtin.Os.freestanding, builtin.Environ.unknown);
    exe.setLinkerScriptPath("src/msp430f5510.ld");

    b.default_step.dependOn(&exe.step);
}
