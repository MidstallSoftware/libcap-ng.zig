const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(std.Build.Step.Compile.Linkage, "linkage", "whether to statically or dynamically link the library") orelse .static;

    const source = b.dependency("libcap-ng", .{});

    const configHeader = b.addConfigHeader(.{
        .style = .{
            .autoconf = source.path("config.h.in"),
        },
        .include_path = "config.h",
    }, .{
        .HAVE_ATTR_XATTR_H = 1,
        .HAVE_DECL_CAP_AUDIT_READ = 1,
        .HAVE_DECL_CAP_BLOCK_SUSPEND = 1,
        .HAVE_DECL_CAP_BPF = 1,
        .HAVE_DECL_CAP_CHECKPOINT_RESTORE = 1,
        .HAVE_DECL_CAP_EPOLLWAKEUP = 1,
        .HAVE_DECL_CAP_PERFMON = 1,
        .HAVE_DECL_CAP_WAKE_ALARM = 1,
        .HAVE_DECL_PR_CAP_AMBIENT = 1,
        .HAVE_DECL_VFS_CAP_REVISION_2 = 1,
        .HAVE_DECL_VFS_CAP_REVISION_3 = 1,
        .HAVE_DLFCN_H = 1,
        .HAVE_INTTYPES_H = 1,
        .HAVE_LINUX_CAPABILITY_H = 1,
        .HAVE_LINUX_MAGIC_H = 1,
        .HAVE_LINUX_SECUREBITS_H = 1,
        .HAVE_PTHREAD_H = 1,
        .HAVE_STDINT_H = 1,
        .HAVE_STDIO_H = 1,
        .HAVE_STDLIB_H = 1,
        .HAVE_STRINGS_H = 1,
        .HAVE_STRING_H = 1,
        .HAVE_SYSCALL_H = 1,
        .HAVE_SYS_STAT_H = 1,
        .HAVE_SYS_TYPES_H = 1,
        .HAVE_SYS_VFS_H = 1,
        .HAVE_SYS_XATTR_H = 1,
        .HAVE_UNISTD_H = 1,
        .LT_OBJDIR = "/lib",
        .PACKAGE = "libcap-ng 0.8.4",
        .PACKAGE_BUGREPORT = "https://github.com/MidstallSoftware/libcap-ng.zig/issues",
        .PACKAGE_NAME = "libcap-ng",
        .PACKAGE_STRING = "\"libcap-ng\"",
        .PACKAGE_TARNAME = "libcap-ng-0.8.4.tar.gz",
        .PACKAGE_URL = "https://people.redhat.com/sgrubb/libcap-ng/",
        .PACKAGE_VERSION = "0.8.4",
        .STDC_HEADERS = 1,
        .VERSION = "0.8.4",
    });

    const libcap = std.Build.Step.Compile.create(b, .{
        .name = "cap-ng",
        .root_module = .{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        },
        .kind = .lib,
        .linkage = linkage,
        .version = .{
            .major = 0,
            .minor = 0,
            .patch = 0,
        },
    });

    libcap.addConfigHeader(configHeader);
    libcap.addIncludePath(source.path("src"));

    libcap.addCSourceFiles(.{
        .files = &.{
            source.path("src/cap-ng.c").getPath(source.builder),
            source.path("src/lookup_table.c").getPath(source.builder),
        },
        .flags = &.{ "-D_GNU_SOURCE" },
    });

    {
        const install_file = b.addInstallFileWithDir(source.path("src/cap-ng.h"), .header, "cap-ng.h");
        b.getInstallStep().dependOn(&install_file.step);
        libcap.installed_headers.append(&install_file.step) catch @panic("OOM");
    }

    b.installArtifact(libcap);

    const libdrop_ambient = std.Build.Step.Compile.create(b, .{
        .name = "drop_ambient",
        .root_module = .{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        },
        .kind = .lib,
        .linkage = linkage,
        .version = .{
            .major = 0,
            .minor = 0,
            .patch = 0,
        },
    });

    libdrop_ambient.addConfigHeader(configHeader);
    libdrop_ambient.addIncludePath(source.path("src"));

    libdrop_ambient.addCSourceFiles(.{
        .files = &.{
            source.path("src/libdrop_ambient.c").getPath(source.builder),
        },
    });

    b.installArtifact(libdrop_ambient);
}
