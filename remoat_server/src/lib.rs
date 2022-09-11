// For the integration tests under `./tests/` to find the functions
// inside the src of the crate we need a `lib.rs` file which exposes
// the functions that are to be tested
//  https://stackoverflow.com/a/59916651/9033629

#![cfg(test)]
pub mod config_parser;
pub mod global;