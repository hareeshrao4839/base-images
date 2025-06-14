#!/usr/bin/env bash
set -e

TMPDIR=${TMPDIR:-/tmp}

# JDK truststore location
JRE_CACERTS_PATH=$JAVA_HOME/lib/security/cacerts

# Opt-in is only activated if the environment variable is set
if [ -n "$USE_SYSTEM_CA_CERTS" ]; then

    if [ ! -w "$TMPDIR" ]; then
        echo "Using additional CA certificates requires write permissions to $TMPDIR. Cannot create truststore."
        exit 1
    fi

    # Figure out whether we can write to the JVM truststore. If we can, we'll add the certificates there. If not,
    # we'll use a temporary truststore.
    if [ ! -w "$JRE_CACERTS_PATH" ]; then
        # We cannot write to the JVM truststore, so we create a temporary one
        JRE_CACERTS_PATH_NEW=$(mktemp)
        echo "Using a temporary truststore at $JRE_CACERTS_PATH_NEW"
        cp "$JRE_CACERTS_PATH" "$JRE_CACERTS_PATH_NEW"
        JRE_CACERTS_PATH=$JRE_CACERTS_PATH_NEW
        # If we use a custom truststore, we need to make sure that the JVM uses it
        export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -Djavax.net.ssl.trustStore=${JRE_CACERTS_PATH} -Djavax.net.ssl.trustStorePassword=changeit"
    fi

    tmp_store=$(mktemp)

    # Copy full system CA store to a temporary location
    trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$tmp_store" > /dev/null

    # Add the system CA certificates to the JVM truststore.
    keytool -importkeystore -destkeystore "$JRE_CACERTS_PATH" -srckeystore "$tmp_store" -srcstorepass changeit -deststorepass changeit -noprompt > /dev/null

    # Clean up the temporary truststore
    rm -f "$tmp_store"

    # Import the additional certificate into JVM truststore
    for i in /certificates/*crt; do
        if [ ! -f "$i" ]; then
            continue
        fi
        tmp_dir=$(mktemp -d)
        BASENAME=$(basename "$i" .crt)

        # We might have multiple certificates in the file. Split this file into single files. The reason is that
        # `keytool` does not accept multi-certificate files
        csplit -s -z -b %02d.crt -f "$tmp_dir/$BASENAME-" "$i" '/-----BEGIN CERTIFICATE-----/' '{*}'

        for crt in "$tmp_dir/$BASENAME"-*; do
            # Extract the Common Name (CN) and Serial Number from the certificate
            CN=$(openssl x509 -in "$crt" -noout -subject -nameopt -space_eq | sed -n 's/^.*CN=\([^,]*\).*$/\1/p')
            SERIAL=$(openssl x509 -in "$crt" -noout -serial | sed -n 's/^serial=\(.*\)$/\1/p')
            
            # Check if an alias with the CN already exists in the keystore
            ALIAS=$CN
            if keytool -list -keystore "$JRE_CACERTS_PATH" -storepass changeit -alias "$ALIAS" >/dev/null 2>&1; then
                # If the CN already exists, append the serial number to the alias
                ALIAS="${CN}_${SERIAL}"
            fi

            echo "Adding certificate with alias $ALIAS to the JVM truststore"

            # Add the certificate to the JVM truststore
            keytool -import -noprompt -alias "$ALIAS" -file "$crt" -keystore "$JRE_CACERTS_PATH" -storepass changeit >/dev/null
        done
    done

    if [ "$(id -u)" -eq 0 ]; then

        if [ -d /certificates ] && [ "$(ls -A /certificates 2>/dev/null)" ]; then
            cp -La /certificates/* /usr/local/share/ca-certificates/
        fi
        update-ca-certificates
    else
        true
    fi
fi

# Let's provide a variable with the correct path for tools that want or need to use it
export JRE_CACERTS_PATH

exec "$@"