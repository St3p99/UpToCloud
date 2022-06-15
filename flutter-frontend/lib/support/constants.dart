// general

// NETWORK
import 'dart:collection';

const bool DEBUG_MODE = false;

const String ADDRESS_STORE_SERVER = "localhost:8180";
const String ADDRESS_AUTHENTICATION_SERVER = "keycloak:8080";

// AUTH
const String REALM = "UpToCloud-Realm";
const String CLIENT_ID = "uptocloud-microservice";
const String CLIENT_SECRET = "558235ab-035a-4886-b3fa-70156f637a6c";
const String REQUEST_LOGIN =
    "/auth/realms/" + REALM + "/protocol/openid-connect/token";

const String REQUEST_LOGOUT =
    "/auth/realms/" + REALM + "/protocol/openid-connect/logout";

// REQUEST PATHS

// - SEARCH CONTROLLER
const String REQUEST_LOAD_RECENT_FILES = "/api/search/recent";
const String REQUEST_LOAD_RECENT_FILES_READ_ONLY =
    "/api/search/recent-read-only";
const int DEFAULT_PAGE_SIZE = 10;

// - USER CONTROLLER
const String REQUEST_ADD_USER = "api/users/new";
const String REQUEST_LOAD_USER = "/api/users";
const String REQUEST_SEARCH_USER_BY_EMAIL = "/api/users/byEmail";
const String REQUEST_SEARCH_USER_BY_EMAIL_CONTAINS = "/api/users/byEmail-contains";
const String REQUEST_NEW_USER = "/api/users/new";

// FILE CONTROLLER
const String REQUEST_ADD_READERS = "/api/files/add-readers";
const String REQUEST_UPLOAD_FILES = "api/files/upload-multiple";
const String REQUEST_UPLOAD_FILE = "api/files/upload";

// ERROR MESSAGE
const String ERROR_RESERVATION_ALREADY_EXIST =
    "ERROR_RESERVATION_ALREADY_EXIST";
const String ERROR_SEATS_UNAVAILABLE = "ERROR_SEATS_UNAVAILABLE";
const String ERROR_REVIEW_ALREADY_EXISTS = "ERROR_REVIEW_ALREADY_EXISTS";

// ROLES

// STORAGE
const String STORAGE_REFRESH_TOKEN = "refresh_token";
const String STORAGE_EMAIL = "email";

// responses
const String RESPONSE_ERROR_MAIL_USER_ALREADY_EXISTS =
    "ERROR_MAIL_USER_ALREADY_EXISTS";

// messages
const String MESSAGE_CONNECTION_ERROR = "connection_error";

const Map<String, String> FILE_TYPE_ICONS_MAP = {
  "text": "txt.svg",
  "image": "image.svg",
  "video": "video.svg",
  "audio": "audio.svg",
  "application/octet-stream": "assets/icons/filetype/binary.svg",
  "application/pdf": "pdf.svg",
  "application/msword": "word.svg",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
      "word.svg",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.template":
      "word.svg",
  "application/vnd.ms-word.document.macroEnabled.12": "word.svg",
  "application/vnd.ms-word.template.macroEnabled.12": "word.svg",
  "application/vnd.ms-excel": "excel.svg",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
      "excel.svg",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.template":
      "excel.svg",
  "application/vnd.ms-excel.sheet.macroEnabled.12": "excel.svg",
  "application/vnd.ms-excel.template.macroEnabled.12": "excel.svg",
  "application/vnd.ms-excel.addin.macroEnabled.12": "excel.svg",
  "application/vnd.ms-excel.sheet.binary.macroEnabled.12": "excel.svg",
  "application/vnd.ms-powerpoint": "pptx.svg",
  "application/vnd.openxmlformats-officedocument.presentationml.presentation":
      "pptx.svg",
  "application/vnd.openxmlformats-officedocument.presentationml.template":
      "pptx.svg",
  "application/vnd.openxmlformats-officedocument.presentationml.slideshow":
      "pptx.svg",
  "application/vnd.ms-powerpoint.addin.macroEnabled.12": "pptx.svg",
  "application/vnd.ms-powerpoint.presentation.macroEnabled.12": "pptx.svg",
  "application/vnd.ms-powerpoint.template.macroEnabled.12": "pptx.svg",
  "application/vnd.ms-powerpoint.slideshow.macroEnabled.12": "pptx.svg",
  "application/vnd.ms-access": "pptx.svg"
};
