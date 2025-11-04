# API Keys Storage

This directory stores your API keys for Claude Code and Gemini CLI.

## Security Notice

**IMPORTANT**: API keys are sensitive credentials. Never commit them to git or share them publicly.

## Setup Instructions

### 1. Create Your API Keys

#### Anthropic (Claude) API Key
1. Visit: https://console.anthropic.com
2. Sign up or log in to your account
3. Navigate to "API Keys" section
4. Click "Create Key"
5. Copy your API key

#### Google AI (Gemini) API Key
1. Visit: https://aistudio.google.com
2. Sign up or log in to your account
3. Navigate to "Get API Key"
4. Click "Create API Key"
5. Copy your API key

### 2. Store Your API Keys

Create the following files in this directory:

#### anthropic.key
```
your-anthropic-api-key-here
```

#### google.key
```
your-google-api-key-here
```

**Note**: Just paste your API key as plain text, with no quotes or extra characters.

### 3. Verify Files Are Gitignored

Run this command to verify your keys won't be committed:
```bash
git status
```

You should NOT see `anthropic.key` or `google.key` in the output.

## File Format

Each key file should contain only the API key, nothing else:
- No quotes
- No variable names
- No extra whitespace
- Just the key itself

## Security Best Practices

1. Never commit API keys to version control
2. Never share API keys in screenshots or documentation
3. Rotate keys periodically
4. Revoke keys immediately if exposed
5. Use separate keys for different projects/environments

## Troubleshooting

### Keys Not Working?
- Check for extra whitespace or line breaks
- Verify the key is valid in the provider's console
- Ensure the key has not expired or been revoked

### Keys Appearing in Git?
- Check your .gitignore file
- Run: `git rm --cached .credentials/*.key`
- Never force-add these files with `git add -f`

## Key Rotation

If you need to rotate your keys:

1. Create new keys in the provider consoles
2. Update the files in this directory
3. Revoke the old keys in the provider consoles
4. Test that the new keys work

## Support

For API key issues:
- Anthropic support: https://support.anthropic.com
- Google AI support: https://ai.google.dev/support
