// Outputs data for Randomisation Module

output "random-string" {
    value           = random_string.random-string.result
}

output "timestamp" {
    value           = local.timestamp
}