/*
 * Copyright (C) 2006 Apple Computer, Inc.
 *
 * Portions are Copyright (C) 2001-6 mozilla.org
 *
 * Other contributors:
 *   Stuart Parmenter <stuart@mozilla.com>
 *
 * Copyright (C) 2007-2009 Torch Mobile, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * Alternatively, the contents of this file may be used under the terms
 * of either the Mozilla Public License Version 1.1, found at
 * http://www.mozilla.org/MPL/ (the "MPL") or the GNU General Public
 * License Version 2.0, found at http://www.fsf.org/copyleft/gpl.html
 * (the "GPL"), in which case the provisions of the MPL or the GPL are
 * applicable instead of those above.  If you wish to allow use of your
 * version of this file only under the terms of one of those two
 * licenses (the MPL or the GPL) and not to allow others to use your
 * version of this file under the LGPL, indicate your decision by
 * deletingthe provisions above and replace them with the notice and
 * other provisions required by the MPL or the GPL, as the case may be.
 * If you do not delete the provisions above, a recipient may use your
 * version of this file under any of the LGPL, the MPL or the GPL.
 */

#include "config.h"
#include "platform/image-decoders/jpeg/JPEGRPIImageDecoder.h"
#include "platform/PlatformInstrumentation.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
FILE *logFile=NULL;

void log(const char * format, ...)
{
    if (!logFile)
    {
        logFile = fopen("/storage/webengine.log", "w");
    }

    va_list args;
    va_start (args, format);
    vfprintf (logFile, format, args);
    fprintf(logFile, "\r\n");
    va_end (args);
    fflush(logFile);
}


#if CPU(BIG_ENDIAN) || CPU(MIDDLE_ENDIAN)
#error Blink assumes a little-endian target.
#endif

namespace
{
    // JPEG only supports a denominator of 8.
    const unsigned scaleDenominator = 8;

} // namespace

namespace blink
{
    BRCMJPEG_T* JPEGImageDecoder::m_decoder=NULL;
    BRCMJPEG_REQUEST_T JPEGImageDecoder::m_dec_request;

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    JPEGImageDecoder::JPEGImageDecoder(ImageSource::AlphaOption alphaOption,
                                       ImageSource::GammaAndColorProfileOption gammaAndColorProfileOption,
                                       size_t maxDecodedBytes)
        : ImageDecoder(alphaOption, gammaAndColorProfileOption, maxDecodedBytes)
    {
        if (!m_decoder)
        {
            BRCMJPEG_STATUS_T status = brcmjpeg_create(BRCMJPEG_TYPE_DECODER, &m_decoder);
            if (status != BRCMJPEG_SUCCESS)
            {
                log("JPEGImageDecoder : could not create HW JPEG decoder");
                brcmjpeg_release(m_decoder);
                m_decoder = NULL;
            }
            else
            {
                log("JPEGImageDecoder : HW JPEG decoder created");
            }

        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    JPEGImageDecoder::~JPEGImageDecoder()
    {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    bool JPEGImageDecoder::isSizeAvailable()
    {
        if (!ImageDecoder::isSizeAvailable())
            decode(true);

        return ImageDecoder::isSizeAvailable();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    bool JPEGImageDecoder::setSize(unsigned width, unsigned height)
    {
        //log("JPEGImageDecoder::setSize to %d x %d", width, height);
        if (!ImageDecoder::setSize(width, height))
            return false;

        if (!desiredScaleNumerator())
            return setFailed();

        return true;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    unsigned JPEGImageDecoder::desiredScaleNumerator() const
    {
        size_t originalBytes = size().width() * size().height() * 4;
        if (originalBytes <= m_maxDecodedBytes) {
            return scaleDenominator;
        }

        // Downsample according to the maximum decoded size.
        unsigned scaleNumerator = static_cast<unsigned>(floor(sqrt(
                                                                  // MSVC needs explicit parameter type for sqrt().
                                                                  static_cast<float>(m_maxDecodedBytes * scaleDenominator * scaleDenominator / originalBytes))));

        return scaleNumerator;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    ImageFrame* JPEGImageDecoder::frameBufferAtIndex(size_t index)
    {
        if (index)
            return 0;

        if (m_frameBufferCache.isEmpty()) {
            m_frameBufferCache.resize(1);
            m_frameBufferCache[0].setPremultiplyAlpha(m_premultiplyAlpha);
        }

        ImageFrame& frame = m_frameBufferCache[0];
        if (frame.status() != ImageFrame::FrameComplete) {
            PlatformInstrumentation::willDecodeImage("JPEG");
            decode(false);
            PlatformInstrumentation::didDecodeImage();
        }

        frame.notifyBitmapIfPixelsChanged();
        return &frame;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    bool JPEGImageDecoder::setFailed()
    {
        log("JPEGImageDecoder::setFailed");
        return ImageDecoder::setFailed();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    bool JPEGImageDecoder::readJpegSize(unsigned int &width, unsigned int &height)
    {
        JFIFHEAD *header = (JFIFHEAD *)m_data->data();
        width = height = 0;

        if (m_data->size() >= (sizeof(*header) - JFIF_DATA_SIZE))
        {
            BYTE* dataptr = header->data;

            while (dataptr < ((BYTE*)header + m_data->size()))
            {
                if (dataptr[0] != 0xFF)
                {
                    log("JPEGImageDecoder::readJpegSize : got wrong marker %d", dataptr[0]);
                    return false;
                }

                // we look for size block marker
                if (dataptr[1] == 0xC0 && dataptr[2] == 0x0)
                {
                    width = (dataptr[8] + dataptr[7] * 256);
                    height = (dataptr[6] + dataptr[5] * 256);
                    return true;
                }

                dataptr += dataptr[3] + (dataptr[2] * 256) + 2;
            }
        }
        else
        {
            log("JPEGImageDecoder::readJpegSize : could not read %d bytes, read %d",sizeof(*header), m_data->size());
            return false;
        }


        log("JPEGImageDecoder::readJpegSize : could not find the proper size marker");
        return false;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    void JPEGImageDecoder::decode(bool onlySize)
    {

        if (failed())
            return;

        if (onlySize)
        {
            unsigned int width, height;
            if (readJpegSize(width, height));
            {
                setSize(width, height);
            }
            return;
        }
        else
        {
            clock_t start = clock();

            // setup decoder request information
            memset(&m_dec_request, 0, sizeof(m_dec_request));
            m_dec_request.input = encodedInBuf;
            m_dec_request.output = decodedBuf;
            m_dec_request.output_handle = 0;
            m_dec_request.output_alloc_size = MAX_DECODED;
            m_dec_request.pixel_format = PIXEL_FORMAT_RGBA;
            m_dec_request.buffer_width = 0;
            m_dec_request.buffer_height = 0;
            m_dec_request.input_size = m_data->size();
            memcpy((char*)encodedInBuf, m_data->data(), m_data->size());


            brcmjpeg_acquire(m_decoder);
            BRCMJPEG_STATUS_T status = brcmjpeg_process(m_decoder, &m_dec_request);

            if (status == BRCMJPEG_SUCCESS)
            {
                if (m_frameBufferCache.isEmpty())
                {
                    log("JPEGImageDecoder::decode : frameBuffercache is empty");
                    setFailed();
                    return;
                }


                ImageFrame& buffer = m_frameBufferCache[0];

                if (buffer.status() == ImageFrame::FrameEmpty)
                {
                    if (!buffer.setSize(m_dec_request.buffer_width, m_dec_request.buffer_height))
                    {
                        log("JPEGImageDecoder::decode : could not define buffer size");
                        setFailed();
                        return;
                    }

                    // The buffer is transparent outside the decoded area while the image is
                    // loading. The completed image will be marked fully opaque in jpegComplete().
                    buffer.setHasAlpha(false);

                    // For JPEGs, the frame always fills the entire image.
                    buffer.setOriginalFrameRect(IntRect(0, 0, m_dec_request.width, m_dec_request.height));
                }

                for (unsigned int i = 0; i < m_dec_request.height; i++)
                {
                    char *dst = (char*)buffer.getAddr(0, i);
                    char *src = (char*)(decodedBuf + (m_dec_request.buffer_width * i * 4));

                    for (int x = 0; x < m_dec_request.buffer_width; x++)
                    {
                        dst[x*4 + 0] = src[x*4 + 2];
                        dst[x*4 + 1] = src[x*4 + 1];
                        dst[x*4 + 2] = src[x*4 + 0];
                        dst[x*4 + 3] = src[x*4 + 3];
                    }
                }

                brcmjpeg_release(m_decoder);

                buffer.setPixelsChanged(true);
                buffer.setStatus(ImageFrame::FrameComplete);

                clock_t end = clock();
                unsigned long millis = (end - start) * 1000 / CLOCKS_PER_SEC;

                log("JPEGImageDecoder::decode : image (%d x %d) decoded successfully in %d ms",m_dec_request.width, m_dec_request.height, millis);
                return;

            }
            else
            {
                log("JPEGImageDecoder::decode : Decoding failed with status %d", status);
                return;
            }

        }

    }
}
