#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H
#include <QObject>
#include <QStringList>
#include <QImage>
#include <QList>
#include <QtQml>

class ImageProcessor : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ImageProcessor(QObject *parent = nullptr);

    Q_INVOKABLE void processImages(const QStringList &filePaths);
    Q_INVOKABLE void saveInvertedImages(const QString &folderpath);
    Q_INVOKABLE QStringList getInvertedImagePaths() const;

signals:
    void imagesLoaded();

private:
    QStringList originalPaths;
    QList<QImage> invertedImages;
    QStringList invertedImagePaths;
};

#endif // IMAGEPROCESSOR_H
