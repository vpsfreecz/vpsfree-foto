/* Original dropzone appearance with native file selection and protected POST. */
function init_dropzone() {
    document.querySelectorAll('form.dropzone').forEach(function (form) {
        var input = form.querySelector('input[type="file"]');
        if (!input || form.dataset.nativeUploadReady) return;
        form.dataset.nativeUploadReady = '1';
        var submit = form.querySelector('button');
        var hint = form.querySelector('div:last-child');
        var choose = document.createElement('button');
        choose.type = 'button'; choose.className = 'file_upload';
        choose.textContent = hint ? hint.textContent : 'Upload images here';
        choose.addEventListener('click', function () { input.click(); });
        input.accept = 'image/jpeg,image/png,image/gif';
        input.setAttribute('aria-label', 'Photographs');
        form.insertBefore(choose, input);
        input.style.display = 'none';
        if (submit) submit.style.display = 'none';
        if (hint) hint.style.display = 'none';
        async function upload() {
            if (!input.files.length) return;
            choose.disabled = true; choose.textContent = 'Uploading…';
            if (input.files.length === 1) {
                form.requestSubmit(submit);
                return;
            }
            // The original proxy limits each request to 10 MiB. As with the old
            // uploader, send individual files rather than one oversized batch.
            try {
                var files = Array.from(input.files);
                for (var index = 0; index < files.length; index++) {
                    choose.textContent = 'Uploading ' + (index + 1) + '/' + files.length + '…';
                    var body = new FormData(form);
                    body.delete('images[]'); body.append('images[]', files[index], files[index].name);
                    var response = await fetch(form.action, {
                        method: 'POST', body: body, credentials: 'same-origin',
                        headers: { 'X-Requested-With': 'XMLHttpRequest' }
                    });
                    if (!response.ok) throw new Error('HTTP ' + response.status);
                }
                var destination = new URL(location.pathname, location.href);
                destination.searchParams.set('f', form.elements.path.value);
                location.assign(destination.href);
            } catch (error) {
                choose.disabled = false;
                choose.textContent = 'Upload failed (' + error.message + '). Reload to see completed files.';
            }
        }
        input.addEventListener('change', upload);
        choose.addEventListener('dragover', function (event) { event.preventDefault(); choose.classList.add('file_upload_highlight'); });
        choose.addEventListener('dragleave', function () { choose.classList.remove('file_upload_highlight'); });
        choose.addEventListener('drop', function (event) {
            event.preventDefault(); choose.classList.remove('file_upload_highlight');
            input.files = event.dataTransfer.files; upload();
        });
    });
}
document.addEventListener('DOMContentLoaded', init_dropzone);
if (window.jQuery) jQuery(document).ajaxComplete(init_dropzone);
