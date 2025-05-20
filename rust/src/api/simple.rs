use rig::{agent::Agent, completion::Prompt, providers::ollama};

use once_cell::sync::Lazy;
use tokio::sync::Mutex;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

static GLOBAL_AGENT: Lazy<Mutex<Agent<ollama::CompletionModel>>> = Lazy::new(|| {
    let client = ollama::Client::new();
    let agent = client.agent("qwen3:30b-a3b").build();
    Mutex::new(agent)
});

pub async fn prompt(message: String) -> String {
    let agent = GLOBAL_AGENT.lock().await;
    let response = agent.prompt(message).await;
    match response {
        Ok(result) => result,
        Err(e) => format!("Error: {}", e),
    }
}
