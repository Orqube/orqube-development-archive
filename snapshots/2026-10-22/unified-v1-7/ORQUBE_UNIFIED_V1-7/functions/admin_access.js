'use strict';
const OWNER_EMAIL = 'byd1009@naver.com';
function isAdminIdentity(token, profile = {}) {
  return profile.disabled !== true && token.email_verified === true && (
    String(token.email || '').toLowerCase() === OWNER_EMAIL ||
    profile.role === 'admin' || profile.isAdmin === true);
}
module.exports = {OWNER_EMAIL, isAdminIdentity};
