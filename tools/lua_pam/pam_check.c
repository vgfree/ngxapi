#include <stdint.h>
#include <stdbool.h>
#include <security/pam_appl.h>
#include <security/pam_misc.h>
#include <sys/types.h>
#include <pwd.h>

int auth_conversation(int num_msg, const struct pam_message **msg, struct pam_response **resp, void *appdata_ptr)
{
	int i, j;
	struct pam_response *value = (struct pam_response *)appdata_ptr;
	struct pam_response *reply = malloc(sizeof(struct pam_response) * num_msg);
	for (i = 0; i < num_msg; i++) {
		reply[i].resp = NULL;  
		reply[i].resp_retcode = 0;  
		if (msg[i]->msg_style == PAM_PROMPT_ECHO_OFF) {
			reply[i].resp = strdup(value->resp);
			if (!reply[i].resp) {
				for (j = 0; j < i; j++) {
					free(reply[j].resp);
				}
				free(reply);
				return PAM_BUF_ERR;
			}
		}
	}
        *resp = reply;
        return PAM_SUCCESS;
}


static int auth_check(char *username, char *password)
{
	struct pam_response reply = {};
	reply.resp = (char *)password;
	reply.resp_retcode = 0;

        struct pam_conv conv = {
                auth_conversation,
                &reply
        };

        pam_handle_t *pamh = NULL;
        int pam_status = pam_start("login", username, &conv, &pamh);
        if (pam_status == PAM_SUCCESS) {
                pam_status = pam_authenticate(pamh, 0);
        }
	if (pamh) {
		pam_end(pamh, pam_status);
	}  

        /* This is where we have been authorized or not. */
        if (pam_status == PAM_SUCCESS) {
		return 0;
        } else {
		return -1;
        }
}

int main(int argc, char **argv)
{
	if (argc != 3) {
		printf("Expected two arguments!\n");
		return -1;
	}

	int ret = auth_check(argv[1], argv[2]);
	if (ret < 0) {
		printf("Auth failed!\n");
	}
	return ret;
}
