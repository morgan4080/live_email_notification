# LiveEmailNotification

To run database

  * Run `docker network create value8-network`
  * Run `docker volume create mysql_data`
  * Run `docker-compose up -d` to start mysql
  * Run `docker exec -it mysql8 mysql -uroot -p` to login
  * Run `UPDATE mysql.user SET host='%' WHERE user='root' AND host='localhost';`
  * Run `FLUSH PRIVILEGES;`
  * Run `exit;`
  * Run `docker restart mysql8`

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

* The system should be able to do the following -

### Problem 1 
 
 * A user should be able to register, then login
 * Users may have up to 2 levels of access;
   a) Frontend Access - manage your own account
   b) Admin Access - manage accounts of any user
 * By default, a frontend user should be able to;
   a) Add contacts
   b) Email a contact
   c) View history of sent emails
   d) Delete sent emails
 * By default, an admin user should be able to;
   a) view a user, with all emails they’ve sent
   b) delete a user with all associated data
 * An admin, with superuser permission, should be able to;
   a) upgrade a user to 'gold' plan, which enables the user to;
   b) retry failed emails
   c) create groups and add contacts to them
   d) send emails to a group
   e) show status of group emails - number sent, number pending and list of failed contacts
   f) grant admin access to a user
   g) revoke admin access to a user

### Solution 1

![BULK_EMAIL_NOTIFICATIONS_ERD.png](assets%2Fimages%2FBULK_EMAIL_NOTIFICATIONS_ERD.jpg)

#### Associations:

PLAN - USERS

One plan can have many users (One-to-Many relationship between PLAN and USERS)


GROUP - GROUP_CONTACTS - CONTACTS

One group can have multiple contacts (One-to-Many relationship between GROUPS and GROUP_CONTACTS)
One contact can be attached to multiple groups (One-to-Many relationship between CONTACTS and GROUP_CONTACTS)

Groups and Contacts have a many-to-many relationship. One group can have many contacts. One contact can be associated with many groups.


GROUP - GROUP_EMAILS - EMAILS

One group can have multiple emails (One-to-Many relationship between GROUPS and GROUP_EMAILS)
One email can be attached to multiple groups (One-to-Many relationship between EMAILS and GROUP_EMAILS)

Groups and Emails have a many-to-many relationship. One group can have many emails. One email can be associated with many groups.


ROLES - ROLE_PERMISSIONS - PERMISSIONS:

One role can have multiple permissions (One-to-Many relationship between ROLES and ROLE_PERMISSIONS).
One permission can be associated with multiple roles (One-to-Many relationship between PERMISSIONS and ROLE_PERMISSIONS).

Roles and permissions have a one-to-many relationship. One role can have many permissions and one permission can be associated with many roles.

USERS - USER_ROLES - ROLES:

One user can have multiple roles (One-to-Many relationship between USERS and USER_ROLES).
One role can be assigned to multiple users (One-to-Many relationship between ROLES and USER_ROLES).

Users and Roles have a many-to-many relationship. One user can have many roles. One role can have many users.

USER - USER_CONTACTS - CONTACTS

One user can have multiple contacts (One-to-Many relationship between USERS and USER_CONTACTS)
One contact can be attached to multiple users (One-to-Many relationship between CONTACTS and USER_CONTACTS)

Users and Contacts have a many-to-many relationship. One user can have many contacts. One contact can be associated with many users.

USER - USER_EMAILS - EMAILS

One user can have multiple emails (One-to-Many relationship between USERS and USER_CONTACT_EMAILS)
One email belongs to one user (One-to-One relationship between EMAILS and USER_CONTACT_EMAILS)

Users and Emails have a one-to-many relationship. One user can have many emails. One email can only belong to one user.


USER - USER_GROUPS - GROUPS

One user can have multiple groups (One-to-Many relationship between USERS and USER_GROUPS)
One group belongs to one user (One-to-One relationship between GROUPS and USER_GROUPS)

Users and Groups have a one-to-many relationship. One user can have many groups.  One group can only belong to one user.