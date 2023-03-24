"""Implementation for `workspace_bazel_binaries`."""

_BAZEL_BINARIES_HELPER_DEFS_BZL = """load("@{rbt_repo_name}//bazel_integration_test/private:integration_test_utils.bzl", "integration_test_utils")

_versions = struct(
    current = "{current_version}",
    other = {other_versions},
    all = {all_versions}
)

bazel_binaries = struct(
    label = integration_test_utils.bazel_binary_label,
    versions = _versions,
)
"""

def _workspace_bazel_binaries_impl(repository_ctx):
    current_version = repository_ctx.attr.current_version
    if current_version == "":
        fail("A current version must be specified.")
    other_versions = repository_ctx.attr.other_versions
    all_versions = sorted([current_version] + other_versions)
    repository_ctx.file("defs.bzl", _BAZEL_BINARIES_HELPER_DEFS_BZL.format(
        rbt_repo_name = repository_ctx.attr.rbt_repo_name,
        current_version = current_version,
        other_versions = other_versions,
        all_versions = all_versions,
    ))
    repository_ctx.file("WORKSPACE")
    repository_ctx.file("BUILD.bazel")

workspace_bazel_binaries = repository_rule(
    implementation = _workspace_bazel_binaries_impl,
    attrs = {
        "current_version": attr.string(
            doc = "The current version.",
            mandatory = True,
        ),
        "other_versions": attr.string_list(
            doc = "The other versions",
        ),
        "rbt_repo_name": attr.string(
            doc = "The name of the rules_bazel_integration_test repo.",
            default = "rules_bazel_integration_test",
        ),
    },
    doc = """\
Provides a default implementation for a `bazel_binaries` repository. This is \
only necessary for repositories that switch back and forth between WORKSPACE \
repositories and bzlmod repositories.\
""",
)