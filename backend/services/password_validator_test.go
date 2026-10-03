package services

import "testing"

func TestValidatePassword(t *testing.T) {
	tests := []struct {
		name     string
		password string
		wantErr  bool
	}{
		{
			name:     "valid password",
			password: "Password@123",
			wantErr:  false,
		},
		{
			name:     "too short",
			password: "Pa@1",
			wantErr:  true,
		},
		{
			name:     "missing lowercase",
			password: "PASSWORD@123",
			wantErr:  true,
		},
		{
			name:     "missing uppercase",
			password: "password@123",
			wantErr:  true,
		},
		{
			name:     "missing number",
			password: "Password@",
			wantErr:  true,
		},
		{
			name:     "missing special character",
			password: "Password123",
			wantErr:  true,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			err := validatePassword(test.password)

			if (err != nil) != test.wantErr {
				t.Errorf(
					"validatePassword(%q) error = %v, wantErr = %v",
					test.password,
					err,
					test.wantErr,
				)
			}
		})
	}
}
