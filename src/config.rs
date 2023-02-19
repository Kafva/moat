#[cfg(target_os = "macos")]
pub const DEFAULT_NEWSBOAT_BIN: &'static str = "/opt/homebrew/bin/newsboat";

#[cfg(not(target_os = "macos"))]
pub const DEFAULT_NEWSBOAT_BIN: &'static str = "/usr/bin/newsboat";

pub const ERR_RESPONSE: &'static str = "{ \"success\": false }";
pub const OK_RESPONSE: &'static str = "{ \"success\": true }";

pub const MOAT_KEY_ENV: &'static str = "MOAT_KEY";

pub const DEFAULT_LOG_LEVEL: &'static str = "info";

#[derive(Clone)]
pub struct Config {
    pub cache_db: String,
    pub newsboat_bin: String,
    pub newsboat_config: String,
    pub urls: String,
}
