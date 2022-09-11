pub fn default_cache_path() -> String {
    return format!("{}/.newsboat/cache.db", std::env::var("HOME").unwrap());
}


