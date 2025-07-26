#include "imageprocessor.h"
#include <QStandardPaths>
#include <QDir>

ImageProcessor::ImageProcessor(QObject *parent)
    : QObject{parent}
{
}

void ImageProcessor::processImages(const QStringList &filePaths)
{
    qDebug() << "Processing" << filePaths.size() << "files";

    if (filePaths.empty()) {
        qDebug() << "No files provided";
        return;
    }

    originalPaths.clear();
    invertedImages.clear();
    invertedImagePaths.clear();

    QString tempDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    QString previewFolder = tempDir + "/ColorInvertPreview";
    QDir().mkpath(previewFolder);

    qDebug() << "Temp folder:" << previewFolder;

    int processedCount = 0;
    for (int i = 0; i < filePaths.size(); ++i)
    {
        QString path = filePaths[i];
        qDebug() << "Original path:" << path;

        if (path.startsWith("file://")) {
            path = path.mid(7);

#ifdef Q_OS_WIN
            if (path.startsWith("/")) {
                path = path.mid(1);
            }
#endif
        }

        qDebug() << "Cleaned path:" << path;

        QImage image(path);
        if (image.isNull()) {
            qDebug() << "Failed to load image:" << path;
            continue;
        }

        qDebug() << "Image loaded successfully, size:" << image.size();

        QImage inverted = image;
        for (int y = 0; y < image.height(); ++y) {
            for (int x = 0; x < image.width(); ++x) {
                QColor color = image.pixelColor(x, y);
                color.setRed(255 - color.red());
                color.setGreen(255 - color.green());
                color.setBlue(255 - color.blue());
                inverted.setPixelColor(x, y, color);
            }
        }

        invertedImages.append(inverted);
        originalPaths.append(path);

        QString tempPath = QString("%1/inverted_preview_%2.png").arg(previewFolder).arg(i + 1);
        if (inverted.save(tempPath)) {
            qDebug() << "Saved preview to:" << tempPath;
            invertedImagePaths.append(tempPath);
            processedCount++;
        } else {
            qDebug() << "Failed to save preview:" << tempPath;
        }
    }

    qDebug() << "Processed" << processedCount << "images successfully";
    qDebug() << "Emitting imagesLoaded signal";
    emit imagesLoaded();
}

void ImageProcessor::saveInvertedImages(const QString &folderpath)
{
    QString cleanPath = folderpath;
    if (cleanPath.startsWith("file://")) {
        cleanPath = cleanPath.mid(7);

#ifdef Q_OS_WIN
        if (cleanPath.startsWith("/")) {
            cleanPath = cleanPath.mid(1);
        }
#endif
    }

    qDebug() << "Saving to folder:" << cleanPath;

    for (int i = 0; i < invertedImages.size(); ++i) {
        const QImage &img = invertedImages[i];
        QString filename = QString("%1/inverted_image_%2.png").arg(cleanPath).arg(i + 1);
        if (img.save(filename)) {
            qDebug() << "Saved:" << filename;
        } else {
            qDebug() << "Failed to save:" << filename;
        }
    }
}

QStringList ImageProcessor::getInvertedImagePaths() const
{
    return invertedImagePaths;
}
