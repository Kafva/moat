use std::fs::File;
use std::io::BufReader;
use std::path::Path;
use std::io::prelude::*; // Needed for .lines()
use super::models::Config;

/// The config file contains newline seperated settings on the form
///     key=value
pub fn get_config(config_path: &str) -> Result<Config, std::io::Error> {

    let file = File::open(config_path)?;
    let buf_reader = BufReader::new(file);
    
    let mut config = Config::new();

    for (i,l) in buf_reader.lines().enumerate() {

        let line  = l.unwrap();
        let mut split = line.split('=');

        match line.split('=').count() {
            // We cannot match directly agianst split.count() since that
            // would generate a "value borrowed here after move" error when
            // calling split.next() 
            2 => {
                let (key,value) = ( split.next().unwrap(), split.next().unwrap() );
                
                if value == "" {
                    panic!("Invalid configuration: Missing value for key at {}:{}", config_path, i+1);
                }
                else if key == "" {
                    panic!("Invalid configuration: Missing key for value at {}:{}", config_path, i+1);
                }

                fn expand_tilde(value: &str) -> String {
                    String::from(value) 
                        .replace("~", std::env::var("HOME").unwrap().as_str()
                    )
                }
                
                match key {
                    "cache_path" => { 
                        config.cache_path = expand_tilde(value)
                    }
                    "newsboat_path" => {
                        config.newsboat_path = expand_tilde(value) 
                    }
                    "muted_list_path" => {
                        config.muted_list = Some(get_muted_list(expand_tilde(value))
                            .expect(&format!(
                                "Invalid configuration: Could not read file referenced at {}:{}", config_path, i+1
                            ))
                        )
                    }
                    _ => {
                        panic!("Invalid configuration: Unrecognized key at {}:{}", config_path, i+1);
                    }
                }
            }
            0..=1 => {
                panic!("Invalid configuration: Missing '=' at {}:{}", config_path, i+1);
            }
            _ => {
                panic!("Invalid configuration: More than one '=' found at {}:{}", config_path, i+1);
            }
        }
    }
    

    // If no muted_list was provided in the config use ~/.newsboat/muted_list (if it exists)
    if config.muted_list == None &&
        Path::new( default_muted_list_path().as_str() ).exists() {
        config.muted_list = Some( get_muted_list( default_muted_list_path() )?)
    }
    
    Ok(config)
}

fn default_muted_list_path() -> String {
    format!("{}/.newsboat/muted_list", std::env::var("HOME").unwrap())
}

/// Returns a vector with the rssurl of every feed that should be muted
pub fn get_muted_list(muted_list_path: String) -> Result<Vec<String>, std::io::Error> {
    let file = File::open(muted_list_path)?;
    let buf_reader = BufReader::new(file);
    
    let mut muted_list = Vec::new();

    for line in buf_reader.lines() {

        muted_list.push(line)
    }
    
    muted_list.into_iter().collect()
}

/******* Tests **********/
// The convention is to include unit tests for functions inside a 
// `mod tests {}` block of each file and to have integration tests
// in the `tests` directory at the same level as `src`
// The cfg(test) attribute ensures that the module is only included
// when running `cargo test`
#[cfg(test)]
mod tests {

    #[test]
    fn test_get_config(){
        let config = super::get_config("./conf/server.conf").unwrap();

        assert_eq!(config.cache_path, 
            format!("{}/.newsboat/cache.db", std::env::var("HOME").unwrap())
        );
    }
    
    #[test]
    #[should_panic(expected = "Invalid configuration: Missing value for key at ./conf/.tests/missing_value.conf:1")]
    fn test_missing_value(){
        super::get_config("./conf/.tests/missing_value.conf").unwrap();
    }
    
    #[test]
    #[should_panic(expected = "Invalid configuration: Missing key for value at ./conf/.tests/missing_key.conf:1")]
    fn test_missing_key(){
        super::get_config("./conf/.tests/missing_key.conf").unwrap();
    }
    
    #[test]
    #[should_panic(expected = "Invalid configuration: Unrecognized key at ./conf/.tests/invalid_key.conf:1")]
    fn test_invalid_key(){
        super::get_config("./conf/.tests/invalid_key.conf").unwrap();
    }
    
    #[test]
    #[should_panic(expected = "Invalid configuration: Missing '=' at ./conf/.tests/missing_equals.conf:1")]
    fn test_missing_equals(){
        super::get_config("./conf/.tests/missing_equals.conf").unwrap();
    }
    
    #[test]
    #[should_panic(expected = "Invalid configuration: More than one '=' found at ./conf/.tests/too_many_equals.conf:1")]
    fn test_too_many_equals(){
        super::get_config("./conf/.tests/too_many_equals.conf").unwrap();
    }
}
