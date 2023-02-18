#[cfg(target_os = "macos")]
pub const DEFAULT_NEWSBOAT_BIN: &'static str = "/opt/homebrew/bin/newsboat";

#[cfg(not(target_os = "macos"))]
pub const DEFAULT_NEWSBOAT_BIN: &'static str = "/usr/bin/newsboat";

pub const MOAT_KEY_ENV: &'static str = "MOAT_KEY";


#[derive(Clone)]
pub struct Config {
    pub cache_db: String,
    pub newsboat_bin: String,
    pub newsboat_config: String,
    pub urls: String,
    pub muted_list: Vec<String>,
}

