// For randomisation data

// For a randomised string - just for testing currently
resource "random_string" "random-string" {
    length              = 16

    // Include the below types - note these will still be used even if the below is set to zero
    upper               = true
    lower               = true
    numeric             = true
    special             = false     // Eg : !@#$%&*()-_=+[]{}<>:?
    // Minimum number of these character types - note this overrides the above and will turn them to True if above zero
    min_upper           = 5
    min_lower           = 5
    min_numeric         = 5
    min_special         = 0

    // Be default a Random will never change once created, however if the below resource changes then it will trigger a change to this random string
    // Optional
    keepers = {
        resource_group = var.force-change-when-different
    }
}

locals {
    // Just for testing - if we want to use the exact current timestamp as a dynamic string
    timestamp           = formatdate("YYYY-MM-DD_hh-mm-ss", timestamp())         // Current timestamp to the second - note timezone agnostic (UTC)
}

    