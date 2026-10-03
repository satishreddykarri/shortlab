package services

import "testing"

func TestValidateCustomAlias(t *testing.T) {
	tests := []struct {
		name    string
		alias   string
		wantErr bool
	}{
		{
			name:    "valid alias",
			alias:   "my-link",
			wantErr: false,
		},
		{
			name:    "valid underscore",
			alias:   "my_link",
			wantErr: false,
		},
		{
			name:    "too short",
			alias:   "ab",
			wantErr: true,
		},
		{
			name:    "too long",
			alias:   "abcdefghijklmnopqrstuvwxyz12345",
			wantErr: true,
		},
		{
			name:    "contains space",
			alias:   "my link",
			wantErr: true,
		},
		{
			name:    "contains special character",
			alias:   "my@link",
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := validateCustomAlias(tt.alias)

			if (err != nil) != tt.wantErr {
				t.Fatalf(
					"validateCustomAlias() error = %v, wantErr = %v",
					err,
					tt.wantErr,
				)
			}
		})
	}
}
