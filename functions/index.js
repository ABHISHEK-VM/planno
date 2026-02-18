const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Triggered when a task is created or updated.
 * Sends a notification if the assigneeId changes and the user is not self-assigning.
 */
exports.onTaskWrite = functions.firestore
  .document("tasks/{taskId}")
  .onWrite(async (change, context) => {
    const newData = change.after.exists ? change.after.data() : null;
    const oldData = change.before.exists ? change.before.data() : null;

    if (!newData) {
      // Task deleted, no notification
      return null;
    }

    const newAssigneeId = newData.assigneeId;
    const oldAssigneeId = oldData ? oldData.assigneeId : null;
    const lastModifiedBy = newData.lastModifiedBy;

    // Check if assignee has changed and is valid
    if (
      newAssigneeId &&
      newAssigneeId !== "" &&
      newAssigneeId !== "current_user" &&
      newAssigneeId !== oldAssigneeId
    ) {
      // Check if self-assigned
      if (newAssigneeId === lastModifiedBy) {
        console.log("Self-assigned task, skipping notification.");
        return null;
      }

      try {
        // Fetch assignee's FCM token
        // Assuming users are stored in 'users' collection with their FCM token
        // NOTE: You must ensure your mobile app saves FCM tokens to users/{userId}/fcmToken
        const userDoc = await admin
          .firestore()
          .collection("users")
          .doc(newAssigneeId)
          .get();

        if (userDoc.exists) {
          const userData = userDoc.data();
          const fcmToken = userData.fcmToken;

          if (fcmToken) {
            const payload = {
              notification: {
                title: "New Task Assigned",
                body: `You have been assigned to task: ${newData.title}`,
              },
              data: {
                taskId: context.params.taskId,
                projectId: newData.projectId,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
              },
            };

            await admin.messaging().sendToDevice(fcmToken, payload);
            console.log(`Notification sent to user ${newAssigneeId}`);
          } else {
            console.log(`No FCM token found for user ${newAssigneeId}`);
          }
        } else {
          console.log(`User ${newAssigneeId} not found`);
        }
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    }

    return null;
  });

/**
 * Triggered when a project is updated (e.g., new member added).
 * Sends a notification to the new member.
 */
exports.onProjectUpdate = functions.firestore
  .document("projects/{projectId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    const newMembers = newData.memberIds || [];
    const oldMembers = oldData.memberIds || [];

    // Find added members
    const addedMembers = newMembers.filter((id) => !oldMembers.includes(id));

    if (addedMembers.length > 0) {
      const projectName = newData.name;

      for (const memberId of addedMembers) {
        // Skip if the member added themselves (unlikely for project creation, but handled for completeness)
        // If you had a 'lastModifiedBy' on projects, you could check it here.
        // For project creation, the creator is usually the first member.
        // For adding members, usually an admin adds them.

        try {
          const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(memberId)
            .get();

          if (userDoc.exists) {
            const userData = userDoc.data();
            const fcmToken = userData.fcmToken;

            if (fcmToken) {
              const payload = {
                notification: {
                  title: "Added to Project",
                  body: `You have been added to project: ${projectName}`,
                },
                data: {
                  projectId: context.params.projectId,
                  click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
              };

              await admin.messaging().sendToDevice(fcmToken, payload);
              console.log(`Notification sent to user ${memberId}`);
            }
          }
        } catch (error) {
          console.error(`Error notifying member ${memberId}:`, error);
        }
      }
    }

    return null;
  });
