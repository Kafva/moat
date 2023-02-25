use crate::moat_error;
use crate::config::{TLS_KEY,TLS_CERT};
use crate::MOAT_KEY_ENV;
use rustls::{
    Certificate,
    PrivateKey,
    ServerConfig
};
use std::{
  io::BufReader,
  fs::File,
  path::Path,
};

pub fn expand_tilde(value: &str) -> String {
    value.replace("~", std::env::var("HOME").unwrap().as_str())
}

pub fn get_env_key() -> String {
    let key = std::env::var(MOAT_KEY_ENV)
              .unwrap_or_else(|_| {
                  moat_error!("Missing '{}'", MOAT_KEY_ENV);
                  panic!("Error retrieving key")
              });
    if key == "" {
        moat_error!("Missing '{}'", MOAT_KEY_ENV);
        panic!("Key is unset")
    }
    key
}

pub fn get_tls_config() -> rustls::ServerConfig {
    let key_file = File::open(TLS_KEY).unwrap_or_else(|_| {
        moat_error!("Missing '{}'", TLS_KEY);
        panic!("No TLS key");
    });
    let cert_file = File::open(TLS_CERT).unwrap_or_else(|_| {
        moat_error!("Missing '{}'", TLS_CERT);
        panic!("No TLS certficate");
    });

    let key_file = &mut BufReader::new(key_file);
    let cert_file = &mut BufReader::new(cert_file);

    let cert_chain = rustls_pemfile::certs(cert_file)
        .unwrap()
        .into_iter()
        .map(Certificate)
        .collect();

    let mut keys = rustls_pemfile::rsa_private_keys(key_file).unwrap();

    ServerConfig::builder()
        .with_safe_defaults()
        .with_no_client_auth()
        .with_single_cert(cert_chain, PrivateKey(keys.remove(0)))
        .unwrap()
}

pub fn path_exists(path_str: &str) -> Result<String,String> {
    let expanded_path = expand_tilde(path_str);
    let filepath = Path::new(expanded_path.as_str());

    if !filepath.is_file() {
        Err("No such file".to_string())
    } else {
        Ok(String::from(path_str))
    }
}

//============================================================================//

#[cfg(test)]
pub fn run_setup_script() {
    std::process::Command::new("./scripts/test_setup.sh").output()
        .expect("Test setup failed");
}



