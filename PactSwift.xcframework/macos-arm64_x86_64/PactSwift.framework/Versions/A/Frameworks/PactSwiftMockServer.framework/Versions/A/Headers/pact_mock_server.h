#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * Request or Response enum
 */
typedef enum {
	/**
	 * Request part
	 */
	Request,
	/**
	 * Response part
	 */
	Response,
} InteractionPart;

/**
 * Wraps a Pact model struct
 */
typedef struct {
	/**
	 * Pact reference
	 */
	uintptr_t pact;
} PactHandle;

/**
 * Result of wrapping a string value
 */
typedef enum {
	/**
	 * Was generated OK
	 */
	Ok,
	/**
	 * There was an error generating the string
	 */
	Failed,
} StringResult_Tag;

typedef struct {
	char *_0;
} Ok_Body;

typedef struct {
	char *_0;
} Failed_Body;

typedef struct {
	StringResult_Tag tag;
	union {
		Ok_Body ok;
		Failed_Body failed;
	};
} StringResult;

/**
 * Wraps a Pact model struct
 */
typedef struct {
	/**
	 * Pact reference
	 */
	uintptr_t pact;
	/**
	 * Interaction reference
	 */
	uintptr_t interaction;
} InteractionHandle;

/**
 * Checks that the example string matches the given regex
 *
 * # Safety
 *
 * Exported functions are inherently unsafe.
 */
bool check_regex(const char *regex, const char *example);

/**
 * External interface to cleanup a mock server. This function will try terminate the mock server
 * with the given port number and cleanup any memory allocated for it. Returns true, unless a
 * mock server with the given port number does not exist, or the function panics.
 *
 * **NOTE:** Although `close()` on the listener for the mock server is called, this does not
 * currently work and the listener will continue handling requests. In this
 * case, it will always return a 404 once the mock server has been cleaned up.
 */
bool cleanup_mock_server(int32_t mock_server_port);

/**
 * External interface to create a mock server. A pointer to the pact JSON as a C string is passed in,
 * as well as the port for the mock server to run on. A value of 0 for the port will result in a
 * port being allocated by the operating system. The port of the mock server is returned.
 *
 * * `pact_str` - Pact JSON
 * * `addr_str` - Address to bind to in the form name:port (i.e. 127.0.0.1:0)
 * * `tls` - boolean flag to indicate of the mock server should use TLS (using a self-signed certificate)
 *
 * # Errors
 *
 * Errors are returned as negative values.
 *
 * | Error | Description |
 * |-------|-------------|
 * | -1 | A null pointer was received |
 * | -2 | The pact JSON could not be parsed |
 * | -3 | The mock server could not be started |
 * | -4 | The method panicked |
 * | -5 | The address is not valid |
 * | -6 | Could not create the TLS configuration with the self-signed certificate |
 *
 */
int32_t create_mock_server(const char *pact_str,
													 const char *addr_str,
													 bool tls);

/**
 * External interface to create a mock server. A Pact handle is passed in,
 * as well as the port for the mock server to run on. A value of 0 for the port will result in a
 * port being allocated by the operating system. The port of the mock server is returned.
 *
 * * `pact` - Handle to a Pact model
 * * `addr_str` - Address to bind to in the form name:port (i.e. 127.0.0.1:0)
 * * `tls` - boolean flag to indicate of the mock server should use TLS (using a self-signed certificate)
 *
 * # Errors
 *
 * Errors are returned as negative values.
 *
 * | Error | Description |
 * |-------|-------------|
 * | -1 | An invalid handle was received |
 * | -3 | The mock server could not be started |
 * | -4 | The method panicked |
 * | -5 | The address is not valid |
 * | -6 | Could not create the TLS configuration with the self-signed certificate |
 *
 */
int32_t create_mock_server_for_pact(PactHandle pact,
																		const char *addr_str,
																		bool tls);

/**
 * Frees the memory allocated to a string by another function
 *
 * # Safety
 *
 * Exported functions are inherently unsafe.
 */
void free_string(char *s);

/**
 * Generates a datetime value from the provided format string, using the current system date and time
 * NOTE: The memory for the returned string needs to be freed with the free_string function
 *
 * # Safety
 *
 * Exported functions are inherently unsafe.
 */
StringResult generate_datetime_string(const char *format);

/**
 * Generates an example string based on the provided regex.
 * NOTE: The memory for the returned string needs to be freed with the free_string function
 *
 * # Safety
 *
 * Exported functions are inherently unsafe.
 */
StringResult generate_regex_value(const char *regex);

/**
 * Fetch the CA Certificate used to generate the self-signed certificate for the TLS mock server.
 *
 * **NOTE:** The string for the result is allocated on the heap, and will have to be freed
 * by the caller using free_string
 *
 * # Errors
 *
 * An empty string indicates an error reading the pem file
 */
char *get_tls_ca_certificate(void);

/**
 * Adds a provider state to the Interaction.
 *
 * * `description` - The provider state description. It needs to be unique.
 */
void given(InteractionHandle interaction, const char *description);

/**
 * Adds a provider state to the Interaction with a parameter key and value.
 *
 * * `description` - The provider state description. It needs to be unique.
 * * `name` - Parameter name.
 * * `value` - Parameter value.
 */
void given_with_param(InteractionHandle interaction,
											const char *description,
											const char *name,
											const char *value);

/**
 * Initialise the mock server library, can provide an environment variable name to use to
 * set the log levels.
 *
 * # Safety
 *
 * Exported functions are inherently unsafe.
 */
void init(const char *log_env_var);

/**
 * External interface to check if a mock server has matched all its requests. The port number is
 * passed in, and if all requests have been matched, true is returned. False is returned if there
 * is no mock server on the given port, or if any request has not been successfully matched, or
 * the method panics.
 */
bool mock_server_matched(int32_t mock_server_port);

/**
 * External interface to get all the mismatches from a mock server. The port number of the mock
 * server is passed in, and a pointer to a C string with the mismatches in JSON format is
 * returned.
 *
 * **NOTE:** The JSON string for the result is allocated on the heap, and will have to be freed
 * once the code using the mock server is complete. The [`cleanup_mock_server`](fn.cleanup_mock_server.html) function is
 * provided for this purpose.
 *
 * # Errors
 *
 * If there is no mock server with the provided port number, or the function panics, a NULL
 * pointer will be returned. Don't try to dereference it, it will not end well for you.
 *
 */
char *mock_server_mismatches(int32_t mock_server_port);

/**
 * Creates a new Interaction and returns a handle to it.
 *
 * * `description` - The interaction description. It needs to be unique for each interaction.
 *
 * Returns a new `InteractionHandle`.
 */
InteractionHandle new_interaction(PactHandle pact, const char *description);

/**
 * Creates a new Pact model and returns a handle to it.
 *
 * * `consumer_name` - The name of the consumer for the pact.
 * * `provider_name` - The name of the provider for the pact.
 *
 * Returns a new `PactHandle`.
 */
PactHandle new_pact(const char *consumer_name, const char *provider_name);

/**
 * Configures the response for the Interaction.
 *
 * * `status` - the response status. Defaults to 200.
 */
void response_status(InteractionHandle interaction, unsigned short status);

/**
 * Sets the description for the Interaction.
 *
 * * `description` - The interaction description. It needs to be unique for each interaction.
 */
void upon_receiving(InteractionHandle interaction, const char *description);

/**
 * Adds a binary file as the body with the expected content type and example contents. Will use
 * a mime type matcher to match the body.
 *
 * * `interaction` - Interaction handle to set the body for.
 * * `part` - Request or response part.
 * * `content_type` - Expected content type.
 * * `body` - example body contents in bytes
 */
void with_binary_file(InteractionHandle interaction,
											InteractionPart part,
											const char *content_type,
											const char *body,
											size_t size);

/**
 * Adds the body for the interaction.
 *
 * * `part` - The part of the interaction to add the body to (Request or Response).
 * * `content_type` - The content type of the body. Defaults to `text/plain`. Will be ignored if a content type
 *   header is already set.
 * * `body` - The body contents. For JSON payloads, matching rules can be embedded in the body.
 */
void with_body(InteractionHandle interaction,
							 InteractionPart part,
							 const char *content_type,
							 const char *body);

/**
 * Configures a header for the Interaction.
 *
 * * `part` - The part of the interaction to add the header to (Request or Response).
 * * `name` - the header name.
 * * `value` - the header value.
 * * `index` - the index of the value (starts at 0). You can use this to create a header with multiple values
 */
void with_header(InteractionHandle interaction,
								 InteractionPart part,
								 const char *name,
								 size_t index,
								 const char *value);

/**
 * Adds a binary file as the body as a MIME multipart with the expected content type and example contents. Will use
 * a mime type matcher to match the body.
 *
 * * `interaction` - Interaction handle to set the body for.
 * * `part` - Request or response part.
 * * `content_type` - Expected content type of the file.
 * * `file` - path to the example file
 * * `part_name` - name for the mime part
 */
StringResult with_multipart_file(InteractionHandle interaction,
																 InteractionPart part,
																 const char *content_type,
																 const char *file,
																 const char *part_name);

/**
 * Configures a query parameter for the Interaction.
 *
 * * `name` - the query parameter name.
 * * `value` - the query parameter value.
 * * `index` - the index of the value (starts at 0). You can use this to create a query parameter with multiple values
 */
void with_query_parameter(InteractionHandle interaction,
													const char *name,
													size_t index,
													const char *value);

/**
 * Configures the request for the Interaction.
 *
 * * `method` - The request method. Defaults to GET.
 * * `path` - The request path. Defaults to `/`.
 */
void with_request(InteractionHandle interaction, const char *method, const char *path);

/**
 * External interface to trigger a mock server to write out its pact file. This function should
 * be called if all the consumer tests have passed. The directory to write the file to is passed
 * as the second parameter. If a NULL pointer is passed, the current working directory is used.
 *
 * Returns 0 if the pact file was successfully written. Returns a positive code if the file can
 * not be written, or there is no mock server running on that port or the function panics.
 *
 * # Errors
 *
 * Errors are returned as positive values.
 *
 * | Error | Description |
 * |-------|-------------|
 * | 1 | A general panic was caught |
 * | 2 | The pact file was not able to be written |
 * | 3 | A mock server with the provided port was not found |
 */
int32_t write_pact_file(int32_t mock_server_port, const char *directory);
